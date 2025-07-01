#!/bin/zsh
# -*- mode: zsh; -*-
# vim: set ft=zsh:

# time-shift-idrac.sh

# This script creates a time-shifted environment for accessing iDRAC6 with expired SSL certificates.

# --- Configuration ---

TARGET_DATE="2020-01-01 12:00:00"
FAKETIME_LIB="/usr/local/lib/faketime/libfaketime.dylib"
JAVA_FAKETIME_AGENT="/usr/local/lib/java-faketime-agent.jar"
FIREFOX_PATH="/Applications/Firefox.app/Contents/MacOS/firefox"
TEMP_PROFILE_DIR=$(mktemp -d -t firefox_profile_XXXX)
JNLP_INTERCEPTOR_SCRIPT="$(dirname "$0")/jnlp-time-interceptor.sh"

# Ensure JNLP_INTERCEPTOR_SCRIPT is an absolute path for Firefox to find it

JNLP_INTERCEPTOR_SCRIPT=$(greadlink -f "$JNLP_INTERCEPTOR_SCRIPT" 2>/dev/null || realpath "$JNLP_INTERCEPTOR_SCRIPT")

JAVA_TIME_WRAPPER_SCRIPT="$(dirname "$0")/java-time-wrapper.sh"

# --- Functions ---

cleanup() {
echo "Cleaning up temporary Firefox profile..."
rm -rf "$TEMP_PROFILE_DIR"
echo "Exiting time-shifted environment." # Restore original time if it was changed by this script (unshare handles this for us) # This is more for user clarity if they were to manually set time outside unshare
}

trap cleanup EXIT

display_instructions() {
echo "--------------------------------------------------------------------------------"
echo "iDRAC6 Time-Shift Environment Ready!"
echo "--------------------------------------------------------------------------------"
echo "1. Firefox has launched with a temporary profile."
echo "2. The system time within this isolated environment is set to: $TARGET_DATE"
echo "3. All new processes launched from this terminal will inherit this time."
echo "4. When prompted to open JNLP files, ensure 'Always open files of this type' is NOT checked."
echo " Select 'Open with' and choose 'Other...' then navigate to and select:"
echo " $JNLP_INTERCEPTOR_SCRIPT"
echo " (You might need to enable 'All Applications' in the file picker if it's greyed out)"
echo "5. To verify the time within this environment, open a new terminal tab/window"
echo " within this same unshare session (e.g., using 'screen')"
}

# --- Main Script ---

# Check for unshare (from coreutils)

if ! command -v unshare &> /dev/null; then
echo "Error: 'unshare' command not found. Please install coreutils: brew install coreutils"
exit 1
fi

# Check for gdate (from coreutils)

if ! command -v gdate &> /dev/null; then
echo "Error: 'gdate' command not found. Please install coreutils: brew install coreutils"
exit 1
fi

# Check if libfaketime.dylib exists

if [ ! -f "$FAKETIME_LIB" ]; then
echo "Error: libfaketime.dylib not found at $FAKETIME_LIB."
echo "Please run 'install-dependencies.sh' first."
exit 1
fi

# Check if java-faketime-agent.jar exists

if [ ! -f "$JAVA_FAKETIME_AGENT" ]; then
echo "Error: java-faketime-agent.jar not found at $JAVA_FAKETIME_AGENT."
echo "Please run 'install-dependencies.sh' first."
exit 1
fi

# Check if Firefox exists

if [ ! -x "$FIREFOX_PATH" ]; then
echo "Error: Firefox not found at $FIREFOX_PATH."
echo "Please ensure Firefox is installed in /Applications/."
exit 1
fi

# Create the unshare command
# -m: unshare mount namespace (for time changes)
# -t: unshare time namespace (macOS Ventura+ for time changes)
# -p: unshare pid namespace (optional, but good for isolation)
# -f: fork the process (so the script can continue to display instructions)

unshare -m -t -p -f sh -c "sudo gdate -s \"$TARGET_DATE\" > /dev/null 2>&1; \
    export DYLD_INSERT_LIBRARIES=\"$FAKETIME_LIB\"; \
    export FAKETIME=\"$TARGET_DATE\"; \
    export FAKETIME_DONT_RESET_SERVERS=1; \
    export FAKETIME_NO_CACHE=1; \
    export JAVA_TOOL_OPTIONS=\"-javaagent:$JAVA_FAKETIME_AGENT\"; \
    export PATH=\"$(dirname "$0"):\$PATH\"; \
    echo \"Time inside unshare: \$(gdate)\"; \
    \"$FIREFOX_PATH\" -no-remote -profile \"$TEMP_PROFILE_DIR\" & \
    echo \"Firefox launched. PID: \$!\"; \
    echo \"Waiting for Firefox to close...\"; \
    wait \$!; \
    echo \"Firefox closed. Exiting unshare environment.\" \"

display_instructions
# The cleanup trap will run automatically when the script exits.
