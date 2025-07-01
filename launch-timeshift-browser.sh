#!/bin/bash
# launch-timeshift-browser.sh
# Launches Chrome with time-shifted environment for accessing iDRAC servers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DATE="2020-01-01 12:00:00"
TARGET_URL="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ -z "$TARGET_URL" ]; then
    print_error "Usage: $0 <URL>"
    echo "Example: $0 https://192.168.1.120"
    exit 1
fi

# Function to find libfaketime
find_libfaketime() {
    local faketime_locations=(
        "/opt/homebrew/Cellar/libfaketime/*/lib/faketime/libfaketime.1.dylib"
        "/usr/local/Cellar/libfaketime/*/lib/faketime/libfaketime.1.dylib"
        "$(brew --prefix libfaketime 2>/dev/null)/lib/faketime/libfaketime.1.dylib"
        "/opt/homebrew/lib/faketime/libfaketime.dylib"
        "/usr/local/lib/faketime/libfaketime.dylib"
    )
    
    for location in "${faketime_locations[@]}"; do
        for file in $location; do
            if [ -f "$file" ]; then
                echo "$file"
                return 0
            fi
        done
    done
    return 1
}

# Function to find Java faketime agent
find_java_agent() {
    local agent_locations=(
        "$HOME/.local/lib/java-faketime-agent.jar"
        "/usr/local/lib/java-faketime-agent.jar"
        "${SCRIPT_DIR}/java-faketime-agent.jar"
        "$(pwd)/java-faketime-agent.jar"
    )
    
    for location in "${agent_locations[@]}"; do
        if [ -f "$location" ]; then
            echo "$location"
            return 0
        fi
    done
    return 1
}

# Check dependencies
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v brew &> /dev/null; then
    print_error "Homebrew not found. Please run ./launch-idrac.sh first to install dependencies."
    exit 1
fi

# Find required libraries
FAKETIME_LIB=""
if ! FAKETIME_LIB=$(find_libfaketime); then
    print_error "libfaketime.dylib not found! Please run ./launch-idrac.sh first."
    exit 1
fi

JAVA_FAKETIME_AGENT=""
if ! JAVA_FAKETIME_AGENT=$(find_java_agent); then
    print_error "java-faketime-agent.jar not found! Please run ./launch-idrac.sh first."
    exit 1
fi

# Find faketime binary
FAKETIME_BIN=""
for location in /opt/homebrew/Cellar/libfaketime/*/bin/faketime /usr/local/Cellar/libfaketime/*/bin/faketime; do
    for file in $location; do
        if [ -f "$file" ]; then
            FAKETIME_BIN="$file"
            break 2
        fi
    done
done

if [ -z "$FAKETIME_BIN" ]; then
    FAKETIME_BIN="$(brew --prefix libfaketime 2>/dev/null)/bin/faketime"
fi

if [ ! -f "$FAKETIME_BIN" ]; then
    print_error "faketime binary not found!"
    exit 1
fi

print_status "Launching time-shifted Chrome for: $TARGET_URL"
print_status "Time set to: $TARGET_DATE"

# Create a temporary Chrome profile for isolation
PROFILE_DIR=$(mktemp -d)
trap "rm -rf \"$PROFILE_DIR\"" EXIT

# Set environment variables for time manipulation
export DYLD_INSERT_LIBRARIES="$FAKETIME_LIB"
export FAKETIME="$TARGET_DATE"
export FAKETIME_DONT_RESET_SERVERS=1
export FAKETIME_NO_CACHE=1
export JAVA_TOOL_OPTIONS="-javaagent:$JAVA_FAKETIME_AGENT"

# Launch Chrome with faketime using temporary profile
"$FAKETIME_BIN" "$TARGET_DATE" "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --user-data-dir="$PROFILE_DIR" \
    --new-window \
    --incognito \
    --ignore-certificate-errors \
    --allow-running-insecure-content \
    "$TARGET_URL" &

CHROME_PID=$!

print_success "Time-shifted Chrome launched with PID $CHROME_PID"
echo ""
echo "🔗 Opening: $TARGET_URL"
echo "⏰ Time: $TARGET_DATE"
echo "🔒 SSL certificates should now be valid"
echo ""
echo "📋 Instructions:"
echo "1. Login with your iDRAC credentials"
echo "2. Click 'Launch Virtual Console' to download JNLP"
echo "3. Configure Chrome to open JNLP files with: ${SCRIPT_DIR}/jnlp-interceptor.sh"
echo ""
echo "🛑 Chrome will close automatically when done"

# Wait for Chrome to exit
wait $CHROME_PID 2>/dev/null || true

print_success "Time-shifted Chrome session ended."