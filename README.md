# Time-Shift iDRAC Solution

A macOS solution for accessing iDRAC6 servers with expired SSL certificates using time-shifted environments.

## Overview

This solution creates isolated namespaces with manipulated system time to allow connections to legacy Dell iDRAC6 interfaces that have expired certificates. It uses `libfaketime` and namespace isolation to create a secure, contained environment where the system time appears to be set to 2020-01-01, allowing SSL certificates from that era to be valid.

## Prerequisites

- macOS Ventura or later
- Administrator privileges (for dependency installation)
- Internet connection (for downloading dependencies)

## Installation

1. **Clone or download this repository**
   ```bash
   git clone <repository-url>
   cd time-shift-idrac
   ```

2. **Run the dependency installation script**
   ```bash
   ./scripts/install-dependencies.sh
   ```

   This will install:
   - Homebrew (if not already installed)
   - coreutils (provides `unshare` and `gdate`)
   - libfaketime (for time manipulation)
   - Java faketime agent

3. **Ensure Firefox is installed**
   - Download and install Firefox from [mozilla.org](https://www.mozilla.org/firefox/)
   - Install to `/Applications/Firefox.app`

## Usage

### Quick Start

1. **Launch the time-shifted environment**
   ```bash
   ./scripts/time-shift-idrac.sh
   ```

2. **Follow the on-screen instructions**
   - Firefox will launch with a temporary profile
   - Navigate to your iDRAC6 interface
   - When prompted to open JNLP files, configure Firefox to use the JNLP interceptor

3. **Configure JNLP handling**
   - When Firefox asks how to handle `.jnlp` files
   - Select "Open with" → "Other..."
   - Navigate to and select: `scripts/jnlp-time-interceptor.sh`
   - DO NOT check "Always open files of this type"

### Manual JNLP Launching

If you have a JNLP file saved locally:

```bash
./scripts/jnlp-time-interceptor.sh /path/to/viewer.jnlp
```

### Java Applications

To run any Java application with time manipulation:

```bash
./scripts/java-time-wrapper.sh -jar your-application.jar
```

## Verification

### Time Verification Commands

Within the time-shifted environment, verify the time manipulation:

```bash
# Check system time (should show 2020-01-01)
gdate

# Check Java time
./scripts/java-time-wrapper.sh -version
```

### SSL Certificate Verification

1. Navigate to your iDRAC6 interface in the time-shifted Firefox
2. Check the certificate details - it should appear valid
3. Launch the Virtual Console JNLP file - it should connect successfully

## File Structure

```
time-shift-idrac/
├── scripts/
│   ├── time-shift-idrac.sh       # Main time-shifting script
│   ├── install-dependencies.sh   # Dependency installer
│   ├── java-time-wrapper.sh      # Java time wrapper
│   ├── jnlp-time-interceptor.sh  # JNLP handler
│   └── MacOS-faketime-browser.zsh # Simple browser example
├── docs/
│   ├── ProjectOverView.md         # Project requirements
│   └── file-structure.md          # Visual project structure
├── viewer.jnlp                    # Example iDRAC6 JNLP file
└── README.md                      # This file
```

## How It Works

1. **Namespace Isolation**: Uses `unshare` to create isolated mount, time, and PID namespaces
2. **Time Manipulation**: Sets system time to 2020-01-01 within the namespace using `gdate`
3. **Library Injection**: Uses `libfaketime.dylib` via `DYLD_INSERT_LIBRARIES` for process time spoofing
4. **Java Integration**: Configures Java processes with faketime agent for JNLP file handling
5. **Browser Launch**: Starts Firefox with temporary profile in the time-shifted environment

## Troubleshooting

### Common Issues

**"unshare: command not found"**
- Run `./scripts/install-dependencies.sh` to install coreutils

**"libfaketime.dylib not found"**
- Run `./scripts/install-dependencies.sh` to install libfaketime
- Ensure Homebrew is properly installed

**Firefox won't launch**
- Verify Firefox is installed in `/Applications/Firefox.app`
- Check Firefox permissions

**JNLP files won't launch**
- Ensure Java is installed on your system
- Configure Firefox to use the JNLP interceptor script
- Try launching JNLP files manually with `./scripts/jnlp-time-interceptor.sh`

**SSL certificates still show as expired**
- Verify time manipulation is working with `gdate`
- Check that you're using the time-shifted Firefox instance
- Ensure the certificate's valid date range includes 2020-01-01

### Debug Mode

For troubleshooting, you can run individual components:

```bash
# Test time manipulation
export FAKETIME="2020-01-01 12:00:00"
export DYLD_INSERT_LIBRARIES="$(brew --prefix)/lib/libfaketime.dylib"
gdate

# Test Java time manipulation
./scripts/java-time-wrapper.sh -version
```

### Logs and Debugging

The scripts provide verbose output during execution. Common debug steps:

1. Verify all dependencies are installed
2. Check that time manipulation is working
3. Ensure Firefox is configured correctly
4. Test JNLP launching manually

## Security Considerations

- Time manipulation is contained within isolated namespaces
- Does not affect host system time permanently
- Temporary Firefox profiles are cleaned up automatically
- Designed for legitimate network administration tasks

## Limitations

- Only works on macOS Ventura and later
- Requires administrator privileges for initial setup
- Firefox must be installed in standard location
- Some Java applications may not respect time manipulation

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Ensure dependencies are properly installed
4. Test individual components in isolation

## License

This tool is designed for legitimate network administration tasks to access legacy Dell iDRAC6 hardware that cannot be updated.