#!/bin/bash
# launch-virtual-console.sh
# One-click Virtual Console launcher for iDRAC servers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DATE="2020-01-01 12:00:00"
IDRAC_IP="$1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ -z "$IDRAC_IP" ]; then
    print_error "Usage: $0 <iDRAC_IP>"
    echo "Example: $0 192.168.1.23"
    exit 1
fi

# Extract IP from URL if full URL provided
if [[ "$IDRAC_IP" =~ https?://([^/]+) ]]; then
    IDRAC_IP="${BASH_REMATCH[1]}"
fi

# Function to find libfaketime
find_libfaketime() {
    local faketime_locations=(
        "/opt/homebrew/Cellar/libfaketime/*/lib/faketime/libfaketime.1.dylib"
        "/usr/local/Cellar/libfaketime/*/lib/faketime/libfaketime.1.dylib"
        "$(brew --prefix libfaketime 2>/dev/null)/lib/faketime/libfaketime.1.dylib"
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

print_status "Launching Virtual Console for iDRAC: $IDRAC_IP"
print_status "Time set to: $TARGET_DATE"

# Create temporary directory for JNLP file
TEMP_DIR=$(mktemp -d)
trap "rm -rf \"$TEMP_DIR\"" EXIT

JNLP_FILE="$TEMP_DIR/viewer.jnlp"

# Download the JNLP file from iDRAC using time-shifted curl
print_status "Downloading JNLP file..."

# Clean environment to avoid conflicts
unset DYLD_INSERT_LIBRARIES
unset FAKETIME
unset FAKETIME_DONT_RESET_SERVERS
unset FAKETIME_NO_CACHE

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

# Try different JNLP URLs that iDRAC6 commonly uses
JNLP_URLS=(
    "https://$IDRAC_IP/viewer.jnlp(192.168.1.23@0@+PowerEdge+R710@iUser_root@+f97e68b0c2630170e277a714b5ffd2e40)"
    "https://$IDRAC_IP/viewer.jnlp"
    "https://$IDRAC_IP/Applications/dellUI/RPC/WEBSES/create.asp?WEBVAR_USERNAME=root&WEBVAR_PASSWD="
)

# Try to download JNLP file
DOWNLOAD_SUCCESS=false
for url in "${JNLP_URLS[@]}"; do
    print_status "Trying: $url"
    if "$FAKETIME_BIN" "$TARGET_DATE" curl -k -s -L "$url" -o "$JNLP_FILE" 2>/dev/null; then
        if [ -s "$JNLP_FILE" ] && grep -q "jnlp" "$JNLP_FILE" 2>/dev/null; then
            DOWNLOAD_SUCCESS=true
            print_success "JNLP file downloaded successfully"
            break
        fi
    fi
done

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    # Create a generic JNLP file for iDRAC6
    print_status "Creating generic iDRAC6 JNLP file..."
    cat > "$JNLP_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<jnlp spec="1.0+" codebase="https://$IDRAC_IP">
  <information>
    <title>iDRAC6 Virtual Console</title>
    <vendor>Dell Inc.</vendor>
    <description>iDRAC6 Virtual Console</description>
  </information>
  <security>
    <all-permissions/>
  </security>
  <resources>
    <j2se version="1.6+"/>
    <jar href="avctKVM.jar" download="eager" main="true"/>
  </resources>
  <application-desc main-class="com.avocent.idrac.kvm.Main">
    <argument>ip=$IDRAC_IP</argument>
    <argument>kmport=5900</argument>
    <argument>vport=5900</argument>
    <argument>apcp=1</argument>
    <argument>reconnect=2</argument>
    <argument>chat=1</argument>
    <argument>F1=1</argument>
    <argument>custom=0</argument>
    <argument>scaling=15</argument>
    <argument>minwinheight=100</argument>
    <argument>minwinwidth=100</argument>
  </application-desc>
</jnlp>
EOF
fi

# Set Java environment for time-shifted execution
export JAVA_TOOL_OPTIONS="-javaagent:$JAVA_FAKETIME_AGENT"

print_status "Launching Virtual Console with time-shifted Java..."

# Find Java Web Start
JAVAWS_CMD=""
if command -v javaws &> /dev/null; then
    JAVAWS_CMD="javaws"
elif [ -f "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/javaws" ]; then
    JAVAWS_CMD="/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/javaws"
elif [ -f "/System/Library/Java/Support/Deploy.bundle/Contents/Home/bin/javaws" ]; then
    JAVAWS_CMD="/System/Library/Java/Support/Deploy.bundle/Contents/Home/bin/javaws"
else
    print_error "Java Web Start not found. Please install Java."
    exit 1
fi

echo ""
echo "🚀 Launching iDRAC6 Virtual Console..."
echo "📡 Server: $IDRAC_IP"  
echo "⏰ Time: $TARGET_DATE"
echo "🔒 SSL certificates valid"
echo ""

# Launch with clean environment and libfaketime only
exec env -i PATH="$PATH" HOME="$HOME" \
    DYLD_INSERT_LIBRARIES="$FAKETIME_LIB" \
    FAKETIME="$TARGET_DATE" \
    FAKETIME_DONT_RESET_SERVERS=1 \
    FAKETIME_NO_CACHE=1 \
    JAVA_TOOL_OPTIONS="-javaagent:$JAVA_FAKETIME_AGENT" \
    "$JAVAWS_CMD" "$JNLP_FILE"