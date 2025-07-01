#!/bin/bash
# jnlp-time-interceptor.sh
# JNLP interceptor that handles Java Web Start with time manipulation

set -e

# Configuration
TARGET_DATE="2020-01-01 12:00:00"
JAVA_FAKETIME_AGENT="/usr/local/lib/java-faketime-agent.jar"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAVA_TIME_WRAPPER="$SCRIPT_DIR/java-time-wrapper.sh"

# Function to display usage
show_usage() {
    echo "Usage: $0 <jnlp_file_path>"
    echo ""
    echo "This script launches JNLP files with faketime set to: $TARGET_DATE"
    echo "It integrates with Java Web Start while preserving time manipulation."
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/viewer.jnlp"
    echo "  $0 ~/Downloads/application.jnlp"
}

# Function to launch JNLP with faketime
launch_jnlp_with_faketime() {
    local jnlp_file="$1"
    
    echo "Launching JNLP file: $jnlp_file"
    echo "Target time: $TARGET_DATE"
    
    # Set environment variables for faketime
    export FAKETIME="$TARGET_DATE"
    export FAKETIME_DONT_RESET_SERVERS=1
    export FAKETIME_NO_CACHE=1
    
    # Check if libfaketime is available
    local faketime_lib
    if [ -f "$(brew --prefix)/lib/faketime/libfaketime.dylib" ]; then
        faketime_lib="$(brew --prefix)/lib/faketime/libfaketime.dylib"
    elif [ -f "$(brew --prefix)/lib/libfaketime.dylib" ]; then
        faketime_lib="$(brew --prefix)/lib/libfaketime.dylib"
    else
        echo "Error: libfaketime.dylib not found"
        exit 1
    fi
    
    export DYLD_INSERT_LIBRARIES="$faketime_lib"
    
    # Add Java faketime agent if available
    if [ -f "$JAVA_FAKETIME_AGENT" ]; then
        export JAVA_TOOL_OPTIONS="-javaagent:$JAVA_FAKETIME_AGENT ${JAVA_TOOL_OPTIONS:-}"
    fi
    
    # Try different Java Web Start launch methods
    if command -v javaws &> /dev/null; then
        echo "Using javaws to launch JNLP..."
        exec javaws "$jnlp_file"
    elif [ -f "/usr/bin/javaws" ]; then
        echo "Using /usr/bin/javaws to launch JNLP..."
        exec /usr/bin/javaws "$jnlp_file"
    elif [ -f "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/javaws" ]; then
        echo "Using Oracle Java javaws to launch JNLP..."
        exec "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/javaws" "$jnlp_file"
    else
        # Fallback: try to launch with java directly
        echo "javaws not found, attempting to launch with java directly..."
        if [ -f "$JAVA_TIME_WRAPPER" ]; then
            exec "$JAVA_TIME_WRAPPER" -jar "$jnlp_file"
        else
            exec java -jar "$jnlp_file"
        fi
    fi
}

# Function to validate JNLP file
validate_jnlp_file() {
    local jnlp_file="$1"
    
    if [ ! -f "$jnlp_file" ]; then
        echo "Error: JNLP file not found: $jnlp_file"
        exit 1
    fi
    
    # Check if file has .jnlp extension
    if [[ ! "$jnlp_file" =~ \.jnlp$ ]]; then
        echo "Warning: File does not have .jnlp extension: $jnlp_file"
    fi
    
    # Basic XML validation (check if file starts with XML declaration or jnlp tag)
    if ! grep -q -E "^<\?xml|^<jnlp" "$jnlp_file" 2>/dev/null; then
        echo "Warning: File may not be a valid JNLP file: $jnlp_file"
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Check for help flags
case "$1" in
    -h|--help|help)
        show_usage
        exit 0
        ;;
esac

# Get JNLP file path
JNLP_FILE="$1"

# Validate the JNLP file
validate_jnlp_file "$JNLP_FILE"

# Check dependencies
if ! command -v java &> /dev/null; then
    echo "Error: Java not found. Please install Java."
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew not found. Please run install-dependencies.sh first."
    exit 1
fi

# Convert relative path to absolute path
JNLP_FILE="$(realpath "$JNLP_FILE")"

echo "Starting JNLP interceptor..."
echo "JNLP file: $JNLP_FILE"
echo "Time will be shifted to: $TARGET_DATE"
echo ""

# Launch JNLP with faketime
launch_jnlp_with_faketime "$JNLP_FILE"