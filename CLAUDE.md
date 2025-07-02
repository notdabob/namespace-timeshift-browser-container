# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS solution for accessing iDRAC6 servers with expired SSL certificates using time-shifted environments. The project creates isolated namespaces with manipulated system time to allow connections to legacy Dell iDRAC6 interfaces that have expired certificates.

## Key Components

- **launch-idrac.sh**: Main all-in-one script that handles everything automatically
- **time-shift-idrac.zsh**: Legacy script for manual namespace time manipulation  
- **MacOS-faketime-browser.zsh**: Simple browser time-shifting example
- **launch-virtual-console.sh**: Direct Virtual Console launcher with time shifting
- **generate_easy_buttons.sh**: Creates .command files for instant access (integrated into main script)
- **viewer.jnlp**: iDRAC6 Virtual Console client configuration file
- **discovered_idracs.json**: Auto-generated database of discovered servers
- **idrac-dashboard.html**: Auto-generated web dashboard for server management

## Core Architecture

The solution uses namespace isolation on macOS to create time-shifted environments:

1. **Namespace Creation**: Uses `unshare -m -t -p -f` to create isolated mount, time, and PID namespaces
2. **Time Manipulation**: Sets system time to 2020-01-01 within the namespace using `gdate`
3. **Library Injection**: Uses `libfaketime.dylib` via `DYLD_INSERT_LIBRARIES` for process time spoofing
4. **Java Integration**: Configures Java processes with faketime agent for JNLP file handling
5. **Browser Launch**: Starts Chrome with temporary profile in the time-shifted environment

## Dependencies

The project requires several macOS tools installed via Homebrew:

- `coreutils` (provides `unshare` and `gdate`)
- `libfaketime` (for time manipulation)
- Chrome (for browser access)
- Java runtime (for JNLP execution)

## Key Environment Variables

- `DYLD_INSERT_LIBRARIES`: Points to libfaketime.dylib
- `FAKETIME`: Target date/time for spoofing
- `JAVA_TOOL_OPTIONS`: Java agent configuration for time manipulation

## Usage Pattern

The main script (`launch-idrac.sh`) provides a complete automated workflow:

1. **Dependency Management**: Auto-installs Homebrew, coreutils, libfaketime, jq, Chrome
2. **Network Discovery**: Scans local network for iDRAC servers on ports 80/443
3. **Dashboard Generation**: Creates HTML interface showing all discovered servers
4. **Easy Access Creation**: Generates .command files for one-click Virtual Console access
5. **Time-Shifted Environment**: Launches Chrome with system time set to 2020-01-01 12:00:00
6. **Automatic Cleanup**: Environment cleans up automatically on exit

### Three Access Methods:
- **Web Dashboard**: Click servers in the HTML interface
- **Easy-Click Buttons**: Double-click .command files in Finder
- **Direct Commands**: Use command-line scripts manually

### Default Credentials:
- **Username**: root
- **Password**: calvin
(Standard Dell iDRAC6 factory defaults)

## Common Development Commands

### Running the Main Script
```bash
./launch-idrac.sh
```
The primary entry point that handles everything automatically.

### Manual Component Scripts
```bash
./launch-virtual-console.sh <IP_ADDRESS>        # Direct Virtual Console access
./launch-timeshift-browser.sh                   # Browser-only time shifting
./generate_easy_buttons.sh                      # Generate .command files
```

### Making Scripts Executable
```bash
chmod +x *.sh
```

## Development Notes

### Script Dependencies
All scripts automatically check and install dependencies via Homebrew. Manual installation is rarely needed, but core dependencies include:
- `brew install coreutils libfaketime jq`
- Chrome browser (auto-downloaded if missing)
- Java runtime (for JNLP handling)

### Testing Network Discovery
The main script scans ports 80/443 on the local network. For testing specific IPs:
```bash
# Test direct IP access
./launch-virtual-console.sh 192.168.1.23
```

### Generated Files
The system auto-generates several files during operation:
- `discovered_idracs.json`: Server database with timestamps
- `idrac-dashboard.html`: Web interface
- `jnlp-interceptor.sh`: JNLP file handler
- `launch-virtual-console-*.command`: Easy-click access files

### Debugging Time Issues
If SSL certificates still appear invalid:
1. Verify `libfaketime` is properly loaded in the environment
2. Check that `FAKETIME` environment variable is set to "2020-01-01 12:00:00"
3. Ensure Chrome is launched from the time-shifted script, not directly

## Security Context

This tool is designed for legitimate network administration tasks to access legacy Dell iDRAC6 hardware that cannot be updated. The time manipulation is contained within isolated namespaces and does not affect the host system permanently.
