#!/bin/bash
cd "\$(dirname "\$0")"#!/bin/bash
# filepath: namespace-timeshift-browser-container/generate_easy_buttons.sh

set -euo pipefail

# Directory containing discovered_idracs.json and launch-virtual-console.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCOVERED_FILE="${SCRIPT_DIR}/discovered_idracs.json"
EASY_BUTTON_PREFIX="launch-virtual-console"

# Check for jq dependency
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: 'jq' is required but not installed."
    exit 1
fi

if [ ! -f "$DISCOVERED_FILE" ]; then
    echo "Error: $DISCOVERED_FILE not found!"
    exit 1
fi

# Parse each server and generate a .command file
jq -r '.servers[]? | select(.status=="online") | .url' "$DISCOVERED_FILE" | while read -r url; do
    # Extract IP/hostname from URL
    ip=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|')
    if [ -z "$ip" ]; then
        echo "Warning: Could not extract IP/hostname from URL: $url"
        continue
    fi
    button_file="${SCRIPT_DIR}/${EASY_BUTTON_PREFIX}-${ip}.command"
    cat > "$button_file" <<EOF

cd "\$(dirname "\$0")"
./launch-virtual-console.sh "$ip"
EOF
    chmod +x "$button_file"
    echo "Created: $button_file"
done

echo
./launch-virtual-console.sh $ip
EOF
    chmod +x "$button_file"
    echo "Created: $button_file"
done

echo "All easy buttons generated!"