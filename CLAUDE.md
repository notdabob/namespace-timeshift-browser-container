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
5. **SSH Key Management**: Provides email-based SSH key generation and deployment
6. **Time-Shifted Environment**: Launches Chrome with system time set to 2020-01-01 12:00:00
7. **Automatic Cleanup**: Environment cleans up automatically on exit

### Three Access Methods

- **Web Dashboard**: Click servers in the HTML interface
- **Easy-Click Buttons**: Double-click .command files in Finder
- **Direct Commands**: Use command-line scripts manually

### Default Credentials

- **Username**: root
- **Password**: calvin
  (Standard Dell iDRAC6 factory defaults)

### SSH Key Management

- **Generate SSH Key**: Creates RSA 4096-bit key pair with admin email
- **Deploy to Servers**: Updates ~/.ssh/config and copies keys to all online servers
- **SSH Aliases**: Servers accessible as `idrac-192-168-1-23` format
- **Key Location**: `~/.ssh/idrac_rsa` (private) and `~/.ssh/idrac_rsa.pub` (public)

## Common Development Commands

### Running the Main Script

```bash
./src/launch-idrac.sh
```

The primary entry point that handles everything automatically. Now located in `src/` directory.

### Manual Component Scripts

```bash
./src/launch-virtual-console.sh <IP_ADDRESS>    # Direct Virtual Console access
./src/launch-timeshift-browser.sh               # Browser-only time shifting
./src/generate_easy_buttons.sh                  # Generate .command files
```

### Making Scripts Executable

```bash
chmod +x src/*.sh
```

### Testing and Validation

```bash
# Test specific iDRAC connection
./src/launch-virtual-console.sh 192.168.1.23

# Verify libfaketime installation
ls -la /opt/homebrew/Cellar/libfaketime/*/lib/faketime/libfaketime.1.dylib

# Check generated files structure
ls -la output/www/downloads/*.command           # Easy-click buttons
cat output/www/data/discovered_idracs.json | jq '.'  # Server database
cat output/www/data/admin_config.json | jq '.'      # Admin configuration

# Test web dashboard locally
open output/www/index.html                      # Open dashboard in browser

# Test SSH key management (after generation)
ls -la ~/.ssh/idrac_rsa*                       # Check SSH keys
cat ~/.ssh/config | grep -A 8 "Host idrac-"    # Check SSH config entries
```

### Web Development and Testing

```bash
# Start local web server for testing (optional)
cd output/www && python3 -m http.server 8080

# View generated web files
ls -la output/www/                              # Web root contents
ls -la output/www/data/                         # JSON data files
ls -la output/www/downloads/                    # Downloadable .command files
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

The system auto-generates several files in the `output/` directory during operation:

- `output/www/data/discovered_idracs.json`: Server database with timestamps
- `output/www/data/admin_config.json`: Admin email and SSH key configuration
- `output/www/index.html`: Web interface dashboard
- `src/jnlp-interceptor.sh`: JNLP file handler (in source directory)
- `output/www/downloads/launch-virtual-console-*.command`: Easy-click access files
- `output/www/downloads/generate-ssh-key.command`: SSH key generation script
- `output/www/downloads/deploy-ssh-keys.command`: SSH key deployment script

### File Organization

**IMPORTANT**: For complete file structure details, always reference `docs/file-structure.md` as the authoritative source of project organization.

- **Source files** (`src/`): Scripts and development files
- **Generated output** (`output/www/`): Web-ready files for hosting
- **Input materials** (`input/diagnostics/`): User-provided debugging materials (screenshots, etc.)
- **Documentation** (`docs/`): Project documentation and diagrams
- **Security**: All generated files and input materials are excluded from git via `.gitignore`

### Debugging Time Issues

If SSL certificates still appear invalid:

1. Verify `libfaketime` is properly loaded in the environment
2. Check that `FAKETIME` environment variable is set to "2020-01-01 12:00:00"
3. Ensure Chrome is launched from the time-shifted script, not directly

## Security Context

This tool is designed for legitimate network administration tasks to access legacy Dell iDRAC6 hardware that cannot be updated. The time manipulation is contained within isolated namespaces and does not affect the host system permanently.

## Documentation Maintenance Requirements

**CRITICAL**: Always update documentation in README.md and CLAUDE.md and update docs/CHANGELOG.md with version updates and keep current the docs/file-structure.md documentation files whenever changes are made to file or folder names, layout, purposes or a change in usage instructions to the user.

## Claude Project Commands

Custom Claude commands for this project live in the `.claude/commands/` directory.

- **To create a new command:**  
  Add a markdown file to `.claude/commands/` (e.g., `optimize.md`). The filename (without .md) becomes the command name.

- **To use a command in Claude Code CLI:**  
  Run `/project:<command_name>` (e.g., `/project:optimize`).

### Available Commands

#### Smart Commit (`/project:commit`)

Automated version management and commit creation:

```bash
/project:commit                    # Auto-detect changes and commit
/project:commit minor             # Force minor version bump
/project:commit -m "Fix issue" patch  # Custom message with patch
/project:commit --dry-run         # Preview changes without committing
```

Features:
- **Auto-detection**: Analyzes file changes to determine appropriate version increment
- **Version Management**: Updates VERSION file and CHANGELOG.md automatically
- **Smart Messages**: Generates contextual commit messages based on changes
- **Claude Attribution**: Includes proper Claude Code attribution in commits

**Version Increment Rules:**
- `patch`: Bug fixes, documentation updates, small improvements
- `minor`: New features, script additions, significant enhancements
- `major`: Breaking changes, major architectural updates

- **Command template example:**

  ```markdown
  # .claude/commands/optimize.md

  Analyze this code for performance issues and suggest optimizations:
  ```
