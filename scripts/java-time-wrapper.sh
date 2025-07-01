#!/bin/bash
# java-time-wrapper.sh
# Java wrapper that calculates time offset and launches Java with faketime

set -e

# Configuration
TARGET_DATE="2020-01-01 12:00:00"
JAVA_FAKETIME_AGENT="/usr/local/lib/java-faketime-agent.jar"

# Function to calculate time offset
calculate_time_offset() {
    local target_timestamp=$(gdate -d "$TARGET_DATE" +%s)
    local current_timestamp=$(gdate +%s)
    local offset=$((target_timestamp - current_timestamp))
    echo "$offset"
}

# Function to launch Java with faketime
launch_java_with_faketime() {
    local java_args="$@"
    local offset=$(calculate_time_offset)
    
    echo "Launching Java with time offset: ${offset} seconds"
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
    
    # Launch Java with all arguments
    exec java "$@"
}

# Function to display usage
show_usage() {
    echo "Usage: $0 [java arguments]"
    echo ""
    echo "This wrapper launches Java with faketime set to: $TARGET_DATE"
    echo "All Java arguments are passed through to the Java process."
    echo ""
    echo "Examples:"
    echo "  $0 -jar myapp.jar"
    echo "  $0 -cp /path/to/classes MyClass"
    echo "  $0 -version"
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

# Check dependencies
if ! command -v java &> /dev/null; then
    echo "Error: Java not found. Please install Java."
    exit 1
fi

if ! command -v gdate &> /dev/null; then
    echo "Error: gdate not found. Please install coreutils: brew install coreutils"
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew not found. Please run install-dependencies.sh first."
    exit 1
fi

# Launch Java with faketime
launch_java_with_faketime "$@"