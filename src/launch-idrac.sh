#!/bin/bash
# launch-idrac.sh
# One-click iDRAC access solution with time-shifted environment
# This single script does everything: dependency check/install, network scan, dashboard generation, and Chrome launch

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${PROJECT_DIR}/output"
WWW_DIR="${OUTPUT_DIR}/www"
DOWNLOADS_DIR="${WWW_DIR}/downloads"
TMP_DIR="${OUTPUT_DIR}/tmp"
LOGS_DIR="${OUTPUT_DIR}/logs"

HTML_FILE="${WWW_DIR}/index.html"
DISCOVERED_FILE="${WWW_DIR}/data/discovered_idracs.json"
TARGET_DATE="2020-01-01 12:00:00"

# Default iDRAC credentials
DEFAULT_USERNAME="root"
DEFAULT_PASSWORD="calvin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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
        # Use glob expansion for wildcard paths
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

# Function to install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Add homebrew paths
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    
    # Check if Homebrew is installed, install if not
    if ! command -v brew &> /dev/null; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for current session
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    
    # coreutils tools like gdate are already in /opt/homebrew/bin
    
    # Install required packages
    print_status "Installing coreutils (unshare, gdate)..."
    brew install coreutils
    
    print_status "Installing libfaketime..."
    brew install libfaketime
    
    # Install Chrome if not present
    if [ ! -d "/Applications/Google Chrome.app" ]; then
        print_status "Installing Chrome..."
        brew install --cask google-chrome
        
        if [ ! -d "/Applications/Google Chrome.app" ]; then
            # Fallback to direct download
            print_status "Downloading Chrome directly..."
            CHROME_DMG="${TMP_DIR}/Chrome.dmg"
            curl -L "https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg" -o "$CHROME_DMG"
            
            hdiutil attach "$CHROME_DMG" -quiet
            cp -R "/Volumes/Google Chrome/Google Chrome.app" "/Applications/"
            hdiutil detach "/Volumes/Google Chrome" -quiet
            rm -f "$CHROME_DMG"
        fi
    fi
    
    # Download Java faketime agent
    print_status "Setting up Java faketime agent..."
    JAVA_AGENT_DIR="$HOME/.local/lib"
    JAVA_AGENT_PATH="$JAVA_AGENT_DIR/java-faketime-agent.jar"
    
    mkdir -p "$JAVA_AGENT_DIR"
    mkdir -p "$WWW_DIR/data"
    mkdir -p "$DOWNLOADS_DIR"
    mkdir -p "$TMP_DIR"
    mkdir -p "$LOGS_DIR"
    
    if [ ! -f "$JAVA_AGENT_PATH" ]; then
        JAVA_AGENT_URL="https://github.com/arvindsv/faketime-java-agent/releases/download/v1.0/faketime-java-agent-1.0.jar"
        curl -L "$JAVA_AGENT_URL" -o "$JAVA_AGENT_PATH"
    fi
    
    print_success "All dependencies installed!"
}

# Function to check dependencies
check_dependencies() {
    local need_install=false
    
    # Add homebrew paths to make sure we can find installed tools
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    
    if ! command -v brew &> /dev/null; then
        need_install=true
    elif ! command -v gdate &> /dev/null; then
        need_install=true
    elif ! brew list libfaketime &> /dev/null; then
        need_install=true
    elif [ ! -d "/Applications/Google Chrome.app" ]; then
        need_install=true
    elif ! find_java_agent > /dev/null; then
        need_install=true
    elif ! find_libfaketime > /dev/null; then
        need_install=true
    fi
    
    if [ "$need_install" = true ]; then
        print_status "Some dependencies are missing. Installing now..."
        install_dependencies
    else
        print_success "All dependencies are ready!"
    fi
}

# Function to initialize JSON file
init_json_file() {
    if [ ! -f "$DISCOVERED_FILE" ]; then
        echo '{"servers": [], "last_scan": "", "scan_count": 0}' > "$DISCOVERED_FILE"
    fi
}

# Function to read current servers from JSON
read_servers_from_json() {
    if [ -f "$DISCOVERED_FILE" ]; then
        cat "$DISCOVERED_FILE"
    else
        echo '{"servers": [], "last_scan": "", "scan_count": 0}'
    fi
}

# Function to add or update server in JSON
update_server_in_json() {
    local url="$1"
    local protocol="$2"
    local title="$3"
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Read current JSON
    local current_json=$(read_servers_from_json)
    
    # Create updated JSON with server info
    echo "$current_json" | python3 -c "
import json
import sys
from datetime import datetime

data = json.load(sys.stdin)
url = '$url'
protocol = '$protocol'
title = '$title'
current_time = '$current_time'

# Find existing server or create new one
server_found = False
for server in data['servers']:
    if server['url'] == url:
        server['title'] = title
        server['protocol'] = protocol
        server['last_seen'] = current_time
        server['status'] = 'online'
        server_found = True
        break

if not server_found:
    new_server = {
        'url': url,
        'protocol': protocol,
        'title': title,
        'first_discovered': current_time,
        'last_seen': current_time,
        'status': 'online'
    }
    data['servers'].append(new_server)

data['last_scan'] = current_time
data['scan_count'] = data.get('scan_count', 0) + 1

print(json.dumps(data, indent=2))
" > "$DISCOVERED_FILE"
}

# Function to mark servers as offline
mark_offline_servers() {
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local current_json=$(read_servers_from_json)
    
    echo "$current_json" | python3 -c "
import json
import sys
from datetime import datetime, timedelta

data = json.load(sys.stdin)
current_time = '$current_time'

# Mark servers as offline if they weren't seen in this scan
for server in data['servers']:
    if server.get('last_seen', '') != current_time and server.get('status') != 'removed':
        server['status'] = 'offline'

print(json.dumps(data, indent=2))
" > "$DISCOVERED_FILE"
}

# Function to scan network for iDRAC servers
scan_network() {
    print_status "Scanning network for iDRAC servers..."
    
    # Initialize JSON file
    init_json_file
    
    # Get local network range
    local network=$(route -n get default | grep interface | awk '{print $2}')
    local ip_range=$(ifconfig "$network" 2>/dev/null | grep 'inet ' | awk '{print $2}' | sed 's/\.[0-9]*$/\./')
    
    if [ -z "$ip_range" ]; then
        ip_range="192.168.1."
        print_warning "Could not detect network range, using default: ${ip_range}0/24"
    fi
    
    # Create temporary file for this scan's results
    local temp_results="${TMP_DIR}/scan_results_$(date +%s).tmp"
    
    # Scan common iDRAC ports in parallel
    local pids=()
    for i in {1..254}; do
        (
            local ip="${ip_range}${i}"
            # Check HTTPS first (more common for iDRAC)
            if timeout 1 bash -c "</dev/tcp/$ip/443" 2>/dev/null; then
                local title="iDRAC Server"
                # Try to get the title from the webpage
                if command -v curl &> /dev/null; then
                    local page_title=$(timeout 3 curl -k -s "https://$ip/" 2>/dev/null | grep -i '<title>' | sed 's/<[^>]*>//g' | tr -d '\n\r' | xargs)
                    if [[ "$page_title" =~ [iI][dD][rR][aA][cC] ]]; then
                        title="$page_title"
                    fi
                fi
                echo "https://$ip|HTTPS|$title" >> "$temp_results"
            # Check HTTP as fallback
            elif timeout 1 bash -c "</dev/tcp/$ip/80" 2>/dev/null; then
                local title="Web Server"
                if command -v curl &> /dev/null; then
                    local page_title=$(timeout 3 curl -s "http://$ip/" 2>/dev/null | grep -i '<title>' | sed 's/<[^>]*>//g' | tr -d '\n\r' | xargs)
                    if [[ "$page_title" =~ [iI][dD][rR][aA][cC] ]]; then
                        title="$page_title"
                        echo "http://$ip|HTTP|$title" >> "$temp_results"
                    fi
                fi
            fi
        ) &
        pids+=($!)
        
        # Limit concurrent processes
        if [ ${#pids[@]} -ge 20 ]; then
            wait "${pids[0]}"
            pids=("${pids[@]:1}")
        fi
    done
    
    # Wait for all background processes
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Process results and update JSON
    local count=0
    if [ -f "$temp_results" ] && [ -s "$temp_results" ]; then
        while IFS='|' read -r url protocol title; do
            if [ -n "$url" ]; then
                update_server_in_json "$url" "$protocol" "$title"
                ((count++))
            fi
        done < "$temp_results"
    fi
    
    # Mark servers not found in this scan as offline
    mark_offline_servers
    
    # Clean up
    rm -f "$temp_results"
    
    print_success "Network scan complete! Found $count active server(s)"
}

# Function to generate easy buttons for discovered servers
generate_easy_buttons() {
    print_status "Generating easy-click buttons..."
    
    if [ ! -f "$DISCOVERED_FILE" ]; then
        print_warning "No discovered servers file found, skipping easy buttons generation"
        return 0
    fi
    
    local button_count=0
    local EASY_BUTTON_PREFIX="launch-virtual-console"
    
    # Check if jq is available, install if needed
    if ! command -v jq &> /dev/null; then
        print_status "Installing jq for JSON parsing..."
        brew install jq
    fi
    
    # Parse each server and generate a .command file
    if command -v jq &> /dev/null; then
        # Use process substitution to avoid subshell and preserve button_count
        while read -r url; do
            if [ -n "$url" ]; then
                # Extract IP from URL
                local ip=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|')
                local button_file="${DOWNLOADS_DIR}/${EASY_BUTTON_PREFIX}-${ip}.command"
                
                cat > "$button_file" <<EOF
#!/bin/bash
cd "\$(dirname "\$0")/../.."
./src/launch-virtual-console.sh $ip
EOF
                chmod +x "$button_file"
                print_success "Created easy button: $(basename "$button_file")"
                ((button_count++))
            fi
        done < <(jq -r '.servers[] | select(.status=="online") | .url' "$DISCOVERED_FILE")
    else
        print_warning "jq not available, skipping easy buttons generation"
        return 0
    fi
    
    if [ $button_count -gt 0 ]; then
        print_success "Generated $button_count easy-click buttons!"
        echo "Double-click any 'launch-virtual-console-*.command' file to instantly connect"
    else
        print_warning "No online servers found for easy button generation"
    fi
}

# Function to generate HTML dashboard
generate_dashboard() {
    print_status "Generating dashboard..."
    
    # Initialize JSON file if it doesn't exist
    init_json_file
    
    # Get server data from JSON
    local json_data=$(read_servers_from_json)
    
    cat > "$HTML_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iDRAC Dashboard - Time-Shifted Environment</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
        }
        
        .header h1 {
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        
        .time-badge {
            background: #e74c3c;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            display: inline-block;
            font-weight: bold;
            margin-top: 10px;
        }
        
        .scan-info {
            background: rgba(52, 152, 219, 0.1);
            border: 1px solid rgba(52, 152, 219, 0.3);
            border-radius: 10px;
            padding: 15px;
            margin: 20px 0;
            text-align: center;
        }
        
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .management-tools {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .management-tools h3 {
            margin-bottom: 15px;
            color: #2c3e50;
        }
        
        .tool-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .tool-button {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        .cleanup-button {
            background: #e74c3c;
            color: white;
        }
        
        .cleanup-button:hover {
            background: #c0392b;
            transform: scale(1.05);
        }
        
        .rescan-button {
            background: #3498db;
            color: white;
        }
        
        .rescan-button:hover {
            background: #2980b9;
            transform: scale(1.05);
        }
        
        .servers-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .server-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
        }
        
        .server-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
        }
        
        .server-card.offline {
            opacity: 0.7;
            border-left: 5px solid #e74c3c;
        }
        
        .server-card.online {
            border-left: 5px solid #27ae60;
        }
        
        .server-status {
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75em;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .status-online {
            background: #d5fdd5;
            color: #27ae60;
        }
        
        .status-offline {
            background: #fdd5d5;
            color: #e74c3c;
        }
        
        .server-title {
            font-size: 1.3em;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
            margin-right: 60px;
        }
        
        .server-url {
            color: #7f8c8d;
            font-size: 0.9em;
            margin-bottom: 15px;
            word-break: break-all;
        }
        
        .server-metadata {
            font-size: 0.8em;
            color: #95a5a6;
            margin-bottom: 15px;
        }
        
        .server-protocol {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: bold;
            margin-bottom: 15px;
        }
        
        .protocol-https {
            background: #27ae60;
            color: white;
        }
        
        .protocol-http {
            background: #f39c12;
            color: white;
        }
        
        .server-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .access-button {
            flex: 1;
            padding: 12px 20px;
            background: linear-gradient(45deg, #3498db, #2980b9);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            text-align: center;
            font-weight: bold;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .access-button:hover {
            background: linear-gradient(45deg, #2980b9, #1f5f8b);
            transform: scale(1.02);
        }
        
        .access-button.disabled {
            background: #95a5a6;
            cursor: not-allowed;
            transform: none;
        }

        .virtual-console-button {
            background: linear-gradient(45deg, #e74c3c, #c0392b) !important;
        }

        .virtual-console-button:hover {
            background: linear-gradient(45deg, #c0392b, #a93226) !important;
        }
        
        .remove-button {
            padding: 12px 15px;
            background: #e74c3c;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        .remove-button:hover {
            background: #c0392b;
            transform: scale(1.05);
        }
        
        .info-box {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .info-title {
            color: #2c3e50;
            font-size: 1.4em;
            margin-bottom: 15px;
            font-weight: bold;
        }
        
        .info-list {
            list-style: none;
            padding-left: 0;
        }
        
        .info-list li {
            padding: 8px 0;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .info-list li:last-child {
            border-bottom: none;
        }
        
        .status-indicator {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #27ae60;
            margin-right: 10px;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        
        .no-servers {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }
        
        .refresh-button {
            background: #9b59b6;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 15px;
        }
        
        .refresh-button:hover {
            background: #8e44ad;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖥️ iDRAC Dashboard</h1>
        <p>Time-Shifted Environment for Legacy SSL Certificates</p>
        <div class="time-badge">
            <span class="status-indicator"></span>
            System Time: January 1, 2020
        </div>
    </div>
    
    <div class="container">
        <div class="info-box">
            <div class="info-title">📋 Instructions</div>
            <ul class="info-list">
                <li>✅ SSL certificates are now valid (time set to 2020)</li>
                <li>🔑 Default credentials: <strong>Username: root | Password: calvin</strong></li>
                <li>🔗 Click "Access iDRAC" to open any server below</li>
                <li>🚀 Launch Virtual Console - JNLP files will work automatically</li>
                <li>⚙️ First time: Configure Chrome to use the JNLP handler when prompted</li>
            </ul>
        </div>

        <div class="scan-info" id="scan-info">
            <div>Loading server information...</div>
        </div>
        
        <div class="management-tools">
            <h3>🛠️ Server Management</h3>
            <div class="tool-buttons">
                <button class="tool-button cleanup-button" onclick="cleanupOfflineServers()">
                    🗑️ Remove Offline Servers
                </button>
                <button class="tool-button rescan-button" onclick="window.location.reload()">
                    🔄 Refresh Dashboard
                </button>
            </div>
        </div>
        
        <div id="servers-container">
            <div class="servers-grid" id="servers-grid">
                <!-- Servers will be populated by JavaScript -->
            </div>
        </div>
    </div>
    
    <script>
        // Server data will be populated here
        const serverData = 
EOF

    # Add JSON data to the script
    echo "$json_data" >> "$HTML_FILE"
    
    cat >> "$HTML_FILE" << 'EOF'
;

        function formatDate(dateString) {
            if (!dateString) return 'Unknown';
            const date = new Date(dateString);
            return date.toLocaleString();
        }

        function timeSince(dateString) {
            if (!dateString) return 'Unknown';
            const now = new Date();
            const date = new Date(dateString);
            const seconds = Math.floor((now - date) / 1000);
            
            if (seconds < 60) return 'Just now';
            if (seconds < 3600) return Math.floor(seconds / 60) + ' minutes ago';
            if (seconds < 86400) return Math.floor(seconds / 3600) + ' hours ago';
            return Math.floor(seconds / 86400) + ' days ago';
        }

        function removeServer(url) {
            if (confirm('Are you sure you want to remove this server from the dashboard?')) {
                // Make a request to remove the server
                fetch('', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({action: 'remove', url: url})
                }).then(() => {
                    window.location.reload();
                }).catch(() => {
                    // Fallback: just reload the page
                    window.location.reload();
                });
            }
        }

        function cleanupOfflineServers() {
            const offlineCount = serverData.servers.filter(s => s.status === 'offline').length;
            if (offlineCount === 0) {
                alert('No offline servers to remove.');
                return;
            }
            
            if (confirm(`Remove ${offlineCount} offline server(s) from the dashboard?`)) {
                // Make a request to cleanup offline servers
                fetch('', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({action: 'cleanup'})
                }).then(() => {
                    window.location.reload();
                }).catch(() => {
                    // Fallback: just reload the page
                    window.location.reload();
                });
            }
        }

        function launchTimeShiftedBrowser(url) {
            // Show instructions for manual launch
            const instructions = `To access ${url} with time-shifted SSL certificates:

1. Open Terminal
2. Navigate to this project directory
3. Run this command:

   ./launch-timeshift-browser.sh "${url}"

This will launch Chrome with SSL certificates valid for 2020.
Click OK and follow the steps above.`;
            
            alert(instructions);
            
            // Also copy the command to clipboard if possible
            try {
                const command = `./launch-timeshift-browser.sh "${url}"`;
                navigator.clipboard.writeText(command).then(() => {
                    console.log('Command copied to clipboard:', command);
                }).catch(() => {
                    console.log('Could not copy to clipboard');
                });
            } catch (e) {
                console.log('Clipboard not available');
            }
        }

        function launchVirtualConsole(url) {
            // Extract IP from URL
            const ip = url.replace(/https?:\/\//, '').replace(/\/.*$/, '');
            
            // Show instructions for Virtual Console launch
            const instructions = `🖥️ ONE-CLICK VIRTUAL CONSOLE for ${ip}

1. Open Terminal
2. Navigate to this project directory  
3. Run this command:

   ./launch-virtual-console.sh ${ip}

This will automatically:
✅ Download the JNLP file
✅ Handle time-shifted SSL certificates
✅ Launch the Virtual Console directly
✅ Bypass macOS JNLP security restrictions

Click OK and run the command above for instant Virtual Console access!`;
            
            alert(instructions);
            
            // Copy the command to clipboard
            try {
                const command = `./launch-virtual-console.sh ${ip}`;
                navigator.clipboard.writeText(command).then(() => {
                    console.log('Virtual Console command copied to clipboard:', command);
                }).catch(() => {
                    console.log('Could not copy to clipboard');
                });
            } catch (e) {
                console.log('Clipboard not available');
            }
        }

        function renderServers() {
            const container = document.getElementById('servers-grid');
            const scanInfo = document.getElementById('scan-info');
            
            // Update scan info
            const totalServers = serverData.servers.length;
            const onlineServers = serverData.servers.filter(s => s.status === 'online').length;
            const offlineServers = serverData.servers.filter(s => s.status === 'offline').length;
            const lastScan = serverData.last_scan ? formatDate(serverData.last_scan) : 'Never';
            
            scanInfo.innerHTML = `
                <div><strong>📊 Network Status:</strong> ${onlineServers} online, ${offlineServers} offline, ${totalServers} total servers</div>
                <div><strong>🕒 Last Scan:</strong> ${lastScan} (Scan #${serverData.scan_count || 0})</div>
            `;

            if (serverData.servers.length === 0) {
                container.innerHTML = `
                    <div class="no-servers">
                        <h3>No iDRAC servers found</h3>
                        <p>The network scan didn't find any servers. You can:</p>
                        <button class="refresh-button" onclick="window.location.reload()">Refresh Page</button>
                        <p style="margin-top: 15px; font-size: 0.9em;">
                            Or manually access your iDRAC by entering its IP address in the Chrome address bar
                        </p>
                    </div>
                `;
                return;
            }

            container.innerHTML = serverData.servers.map(server => {
                const protocolClass = `protocol-${server.protocol.toLowerCase()}`;
                const statusClass = `status-${server.status}`;
                const cardClass = server.status;
                const isOffline = server.status === 'offline';
                
                return `
                    <div class="server-card ${cardClass}">
                        <div class="server-status ${statusClass}">${server.status}</div>
                        <div class="server-title">${server.title}</div>
                        <div class="server-url">${server.url}</div>
                        <div class="server-metadata">
                            <div>First seen: ${formatDate(server.first_discovered)}</div>
                            <div>Last seen: ${timeSince(server.last_seen)}</div>
                        </div>
                        <div class="server-protocol ${protocolClass}">${server.protocol}</div>
                        <div class="server-actions">
                            <button class="access-button ${isOffline ? 'disabled' : ''}" 
                               onclick="${isOffline ? 'return false;' : `launchTimeShiftedBrowser('${server.url}')`}" 
                               ${isOffline ? 'disabled' : ''}>
                               ${isOffline ? '⚠️ Offline' : '🔗 Access iDRAC'}
                            </button>
                            <button class="access-button virtual-console-button ${isOffline ? 'disabled' : ''}" 
                               onclick="${isOffline ? 'return false;' : `launchVirtualConsole('${server.url}')`}" 
                               ${isOffline ? 'disabled' : ''}>
                               ${isOffline ? '⚠️ Offline' : '🖥️ Virtual Console'}
                            </button>
                            <button class="remove-button" onclick="removeServer('${server.url}')" title="Remove from dashboard">
                                ❌
                            </button>
                        </div>
                    </div>
                `;
            }).join('');
        }

        // Initialize the dashboard
        document.addEventListener('DOMContentLoaded', function() {
            renderServers();
            
            // Add hover effects
            const serverCards = document.querySelectorAll('.server-card');
            serverCards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    if (!this.classList.contains('offline')) {
                        this.style.transform = 'translateY(-5px) scale(1.02)';
                    }
                });
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0) scale(1)';
                });
            });
        });
    </script>
</body>
</html>
EOF

    print_success "Dashboard generated: $HTML_FILE"
}

# Function to create JNLP interceptor
create_jnlp_interceptor() {
    local jnlp_script="${SCRIPT_DIR}/jnlp-interceptor.sh"
    
    cat > "$jnlp_script" << 'EOF'
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
EOF

    chmod +x "$jnlp_script"
}

# Function to launch time-shifted Chrome
launch_chrome() {
    print_status "Starting time-shifted Chrome environment..."
    
    local HTML_FILE_ABS=$(realpath "$HTML_FILE")
    
    # Find required libraries
    local FAKETIME_LIB
    if ! FAKETIME_LIB=$(find_libfaketime); then
        print_error "libfaketime.dylib not found!"
        exit 1
    fi
    
    local JAVA_FAKETIME_AGENT
    if ! JAVA_FAKETIME_AGENT=$(find_java_agent); then
        print_error "java-faketime-agent.jar not found!"
        exit 1
    fi
    
    # Create JNLP interceptor
    create_jnlp_interceptor
    local JNLP_INTERCEPTOR_SCRIPT="${SCRIPT_DIR}/jnlp-interceptor.sh"
    
    # Find faketime binary
    local FAKETIME_BIN="/opt/homebrew/Cellar/libfaketime/*/bin/faketime"
    for file in $FAKETIME_BIN; do
        if [ -f "$file" ]; then
            FAKETIME_BIN="$file"
            break
        fi
    done
    
    if [ ! -f "$FAKETIME_BIN" ]; then
        FAKETIME_BIN="$(brew --prefix libfaketime)/bin/faketime"
    fi
    
    # Display instructions
    echo ""
    echo "=================================================================================="
    echo "🚀 iDRAC Time-Shift Environment Started!"
    echo "=================================================================================="
    echo "✅ System time set to: $TARGET_DATE"
    echo "✅ SSL certificates are now valid for legacy iDRAC6 servers"
    echo "✅ Chrome launched with dashboard"
    echo ""
    echo "📋 Instructions:"
    echo "1. Use the dashboard to click on any iDRAC server"
    echo "2. Login with default credentials: Username: root | Password: calvin"
    echo "3. Click 'Launch Virtual Console' - JNLP files will be handled automatically"
    echo "4. First time: Configure Chrome to use: $JNLP_INTERCEPTOR_SCRIPT"
    echo ""
    echo "🔧 Dashboard URL: file://$HTML_FILE_ABS"
    echo "🛑 Close Chrome window to exit"
    echo "=================================================================================="
    echo ""
    
    echo "Time manipulation active: $TARGET_DATE"
    echo "Starting Chrome with dashboard..."
    echo ""
    
    # Set Java environment for JNLP handling
    export JAVA_TOOL_OPTIONS="-javaagent:$JAVA_FAKETIME_AGENT"
    
    # Launch Chrome using faketime with the dashboard
    "$FAKETIME_BIN" "$TARGET_DATE" open -a "Google Chrome" "file://$HTML_FILE_ABS"
    
    echo "Chrome launched with time-shifted environment"
    echo "Time manipulation will apply to any iDRAC sites accessed from this Chrome instance"
    echo ""
    echo "Press Enter when done to exit..."
    read -r
    
    print_success "Time-shifted environment session ended."
}

# Main function
main() {
    local test_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --test)
                test_mode=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    echo "🖥️  One-Click iDRAC Access Solution"
    echo "===================================="
    echo ""
    
    print_status "Step 1/4: Checking dependencies..."
    check_dependencies
    echo ""
    
    print_status "Step 2/4: Scanning network for iDRAC servers..."
    scan_network
    echo ""
    
    print_status "Step 3/5: Generating dashboard..."
    generate_dashboard
    echo ""
    
    print_status "Step 4/5: Creating easy-click buttons..."
    generate_easy_buttons
    echo ""
    
    if [ "$test_mode" = true ]; then
        print_success "Test mode complete! Dashboard and easy buttons generated at: $HTML_FILE"
        print_status "To launch Chrome, run: $0 (without --test)"
    else
        print_status "Step 5/5: Launching time-shifted Chrome..."
        launch_chrome
    fi
}

# Check for help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "One-Click iDRAC Access Solution"
    echo ""
    echo "This script does everything automatically:"
    echo "1. Installs all required dependencies"
    echo "2. Scans your network for iDRAC servers"
    echo "3. Creates a beautiful dashboard webpage"
    echo "4. Generates easy-click .command files for instant access"
    echo "5. Launches Chrome with time-shifted SSL certificates"
    echo ""
    echo "Usage: $0 [--test]"
    echo ""
    echo "Options:"
    echo "  --test    Test mode (don't launch Chrome)"
    echo ""
    echo "Just double-click this script and everything works!"
    exit 0
fi

# Run main function
main "$@"