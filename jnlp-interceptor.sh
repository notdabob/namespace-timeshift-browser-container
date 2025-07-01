#!/bin/bash
# Inline JNLP interceptor for time-shifted Java applications

JNLP_FILE="$1"
TARGET_DATE="2020-01-01 12:00:00"

if [ ! -f "$JNLP_FILE" ]; then
    echo "Error: JNLP file not found: $JNLP_FILE"
    exit 1
fi

# Find libfaketime
FAKETIME_LIB=""
for location in /opt/homebrew/Cellar/libfaketime/*/lib/faketime/libfaketime.1.dylib /usr/local/Cellar/libfaketime/*/lib/faketime/libfaketime.1.dylib; do
    for file in $location; do
        if [ -f "$file" ]; then
            FAKETIME_LIB="$file"
            break 2
        fi
    done
done

# Find Java agent
JAVA_AGENT=""
for location in "$HOME/.local/lib/java-faketime-agent.jar" "/usr/local/lib/java-faketime-agent.jar"; do
    if [ -f "$location" ]; then
        JAVA_AGENT="$location"
        break
    fi
done

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

# Set environment
export DYLD_INSERT_LIBRARIES="$FAKETIME_LIB"
export FAKETIME="$TARGET_DATE"
export FAKETIME_DONT_RESET_SERVERS=1
export FAKETIME_NO_CACHE=1

if [ -n "$JAVA_AGENT" ]; then
    export JAVA_TOOL_OPTIONS="-javaagent:$JAVA_AGENT"
fi

echo "Launching JNLP with faketime: $TARGET_DATE"

# Launch JNLP with environment variables
if command -v javaws &> /dev/null; then
    exec env DYLD_INSERT_LIBRARIES="$FAKETIME_LIB" FAKETIME="$TARGET_DATE" FAKETIME_DONT_RESET_SERVERS=1 FAKETIME_NO_CACHE=1 JAVA_TOOL_OPTIONS="-javaagent:$JAVA_AGENT" javaws "$JNLP_FILE"
elif [ -f "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/javaws" ]; then
    exec env DYLD_INSERT_LIBRARIES="$FAKETIME_LIB" FAKETIME="$TARGET_DATE" FAKETIME_DONT_RESET_SERVERS=1 FAKETIME_NO_CACHE=1 JAVA_TOOL_OPTIONS="-javaagent:$JAVA_AGENT" "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/javaws" "$JNLP_FILE"
else
    exec env DYLD_INSERT_LIBRARIES="$FAKETIME_LIB" FAKETIME="$TARGET_DATE" FAKETIME_DONT_RESET_SERVERS=1 FAKETIME_NO_CACHE=1 JAVA_TOOL_OPTIONS="-javaagent:$JAVA_AGENT" java -jar "$JNLP_FILE"
fi
