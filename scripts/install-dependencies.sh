#!/bin/bash
# install-dependencies.sh
# Installs all required dependencies for the time-shift iDRAC solution

set -e

echo "Installing dependencies for time-shift iDRAC solution..."

# Check if Homebrew is installed, install if not
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed."
fi

# Install coreutils (provides unshare and gdate)
echo "Installing coreutils..."
brew install coreutils

# Install libfaketime
echo "Installing libfaketime..."
brew install libfaketime

# Create directory for Java faketime agent if it doesn't exist
sudo mkdir -p /usr/local/lib

# Download Java faketime agent
echo "Downloading Java faketime agent..."
JAVA_AGENT_URL="https://github.com/arvindsv/faketime-java-agent/releases/download/v1.0/faketime-java-agent-1.0.jar"
sudo curl -L "$JAVA_AGENT_URL" -o /usr/local/lib/java-faketime-agent.jar

# Verify downloads
if [ ! -f /usr/local/lib/java-faketime-agent.jar ]; then
    echo "Error: Failed to download java-faketime-agent.jar"
    exit 1
fi

# Check if Firefox is installed
if [ ! -d "/Applications/Firefox.app" ]; then
    echo "Warning: Firefox not found in /Applications/. Please install Firefox manually."
    echo "Download from: https://www.mozilla.org/firefox/"
else
    echo "Firefox found."
fi

# Verify libfaketime installation
if brew list libfaketime &> /dev/null; then
    FAKETIME_LIB=$(brew --prefix)/lib/faketime/libfaketime.dylib
    if [ -f "$FAKETIME_LIB" ]; then
        echo "libfaketime installed at: $FAKETIME_LIB"
    else
        # Try alternative location
        FAKETIME_LIB=$(brew --prefix)/lib/libfaketime.dylib
        if [ -f "$FAKETIME_LIB" ]; then
            echo "libfaketime installed at: $FAKETIME_LIB"
        else
            echo "Warning: libfaketime.dylib not found in expected locations"
        fi
    fi
else
    echo "Error: libfaketime installation failed"
    exit 1
fi

echo ""
echo "Dependencies installation completed!"
echo ""
echo "Installed components:"
echo "- Homebrew (package manager)"
echo "- coreutils (unshare, gdate)"
echo "- libfaketime (time manipulation)"
echo "- Java faketime agent (/usr/local/lib/java-faketime-agent.jar)"
echo ""
echo "Next steps:"
echo "1. Ensure Firefox is installed in /Applications/"
echo "2. Run ./scripts/time-shift-idrac.sh to start the time-shifted environment"
echo ""