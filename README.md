# Time-Shift iDRAC Solution

A macOS solution for accessing iDRAC6 servers with expired SSL certificates using time-shifted environments.

## Overview

This solution uses time manipulation to allow connections to legacy Dell iDRAC6 interfaces that have expired certificates. It uses `libfaketime` to create a secure, contained environment where applications see the system time as 2020-01-01, allowing SSL certificates from that era to be valid.

## Prerequisites

- macOS Ventura or later
- Administrator privileges (may be needed for dependency installation)
- Internet connection (for downloading dependencies)

## 🚀 One-Click Magic Solution

**This is now a single-click solution!** No setup, no multiple steps, just one click and you're done.

### Usage

1. **Run the main script**

   ```bash
   ./src/launch-idrac.sh
   ```

That's literally it! 🎉

The script automatically:

- ✅ Checks and installs ALL dependencies (Homebrew, Chrome, etc.)
- ✅ Scans your network for iDRAC servers and tracks their status
- ✅ Creates a beautiful dashboard with server management features
- ✅ **NEW:** Generates easy-click .command files for instant Virtual Console access
- ✅ Opens time-shifted Chrome with valid SSL certificates
- ✅ Shows you clickable links to all your iDRAC servers
- ✅ Handles JNLP files automatically for Virtual Console access
- ✅ Tracks when servers were first/last seen for easy management
- ✅ Provides one-click cleanup of offline servers

### Three Ways to Access iDRAC

**🔥 FASTEST - Easy-Click Buttons (NEW!)**
After running the script once, you'll find `.command` files in the output folder:

- `output/www/downloads/launch-virtual-console-192.168.1.23.command`
- `output/www/downloads/launch-virtual-console-192.168.1.45.command`
- etc.

Just **double-click any .command file** for instant Virtual Console access!

**Dashboard Method**
Use the HTML dashboard that opens automatically:

- Click "🔗 Access iDRAC" for web interface
- Click "🖥️ Virtual Console" for JNLP download

**Command Line Method**

```bash
./src/launch-virtual-console.sh 192.168.1.23
```

### 🔑 Default Credentials

All iDRAC servers use these default credentials:

- **Username:** `root`
- **Password:** `calvin`

These are the standard Dell iDRAC6 factory defaults.

### First Time JNLP Setup (One Time Only)

The very first time you use Virtual Console:

1. Chrome will ask what to do with the `.jnlp` file
2. Click "Open with" → "Choose..."
3. Navigate to your project folder
4. Select `src/jnlp-interceptor.sh` (created automatically)
5. Check "Always open with this application"

After that, all JNLP files will work automatically!

### That's Really It

No advanced options needed - the script does everything for you automatically. Just run `./src/launch-idrac.sh` whenever you need to access your iDRAC servers.

## File Structure

```
namespace-timeshift-browser-container/
├── src/                                    # 🚀 Source scripts
│   ├── launch-idrac.sh                     # THE MAGIC SCRIPT - run this!
│   ├── launch-virtual-console.sh           # Direct Virtual Console launcher
│   ├── launch-timeshift-browser.sh         # Browser-only time shifting
│   ├── generate_easy_buttons.sh            # Easy button generator (integrated)
│   └── jnlp-interceptor.sh                 # JNLP handler (auto-generated)
├── output/                                 # 🎯 Generated files (not in git)
│   └── www/                                # Web-ready files for hosting
│       ├── index.html                      # Dashboard webpage (auto-generated)
│       ├── data/
│       │   └── discovered_idracs.json      # Server database (auto-generated)
│       └── downloads/
│           └── *.command                   # 🔥 Easy-click buttons (auto-generated)
├── docs/                                  # Documentation  
├── .gitignore                             # Excludes generated output files
└── README.md                              # This file
```

**Web-Ready Structure!** The `output/www/` folder can be directly hosted by any web server, while source files are organized in `src/`.

## How It Works

Behind the scenes, the magic script:

1. **Auto-installs everything**: Homebrew, coreutils, libfaketime, jq, Chrome, Java agents
2. **Scans your network**: Finds all iDRAC servers automatically on ports 80/443
3. **Creates a dashboard**: Beautiful webpage with all your servers and status tracking
4. **Generates easy buttons**: Creates .command files for instant Virtual Console access
5. **Time manipulation**: Uses libfaketime to make applications see 2020-01-01 for valid SSL certificates
6. **Launches Chrome**: With time manipulation active and the dashboard loaded

## Troubleshooting

### If something goes wrong

**Problem: Script won't run**

- Make sure you're running `./src/launch-idrac.sh`
- The script needs to be executable: `chmod +x src/launch-idrac.sh`

**Problem: No iDRAC servers found**

- The script scans your local network automatically
- You can manually navigate to your iDRAC IP in the opened Chrome window

**Problem: JNLP files don't work**

- First time: Configure Chrome to use the `src/jnlp-interceptor.sh` script
- The script creates this file automatically and tells you exactly where it is

**Problem: Still getting SSL errors**

- Make sure you're using the Chrome window opened by the script
- Don't use your regular Chrome browser

That's pretty much it - the script handles everything else automatically!

## Security Considerations

- Time manipulation is contained within isolated namespaces
- Does not affect host system time permanently
- Temporary Chrome profiles are cleaned up automatically
- Designed for legitimate network administration tasks

## License

This tool is designed for legitimate network administration tasks to access legacy Dell iDRAC6 hardware that cannot be updated.
