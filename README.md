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

1. **Double-click the script**
   ```bash
   ./launch-idrac.sh
   ```

That's literally it! 🎉

The script automatically:
- ✅ Checks and installs ALL dependencies (Homebrew, Chrome, etc.)
- ✅ Scans your network for iDRAC servers and tracks their status
- ✅ Creates a beautiful dashboard with server management features
- ✅ Opens time-shifted Chrome with valid SSL certificates
- ✅ Shows you clickable links to all your iDRAC servers
- ✅ Handles JNLP files automatically for Virtual Console access
- ✅ Tracks when servers were first/last seen for easy management
- ✅ Provides one-click cleanup of offline servers

### First Time JNLP Setup

The very first time you click "Launch Virtual Console" on any iDRAC:

1. Chrome will ask what to do with the `.jnlp` file
2. Click "Open with" → "Choose..." 
3. Navigate to your project folder
4. Select `jnlp-interceptor.sh` (created automatically)
5. **Don't** check "Do this automatically"

After that, all JNLP files will work automatically!

### That's Really It!

No advanced options needed - the script does everything for you automatically. Just double-click `launch-idrac.sh` whenever you need to access your iDRAC servers.

## File Structure

```
time-shift-idrac/
├── launch-idrac.sh               # 🚀 THE MAGIC SCRIPT - just double-click this!
├── discovered_idracs.json        # Server database (auto-generated)
├── idrac-dashboard.html          # Dashboard webpage (auto-generated)
├── jnlp-interceptor.sh           # JNLP handler (auto-generated)
├── docs/                        # Documentation  
├── viewer.jnlp                  # Example iDRAC6 JNLP file
└── README.md                    # This file
```

**Clean & Simple!** Everything you need is in one script - no more scattered files or complex folder structures.

## How It Works

Behind the scenes, the magic script:

1. **Auto-installs everything**: Homebrew, coreutils, libfaketime, Chrome, Java agents
2. **Scans your network**: Finds all iDRAC servers automatically 
3. **Creates a dashboard**: Beautiful webpage with all your servers
4. **Time manipulation**: Uses libfaketime to make applications see 2020-01-01 for valid SSL certificates
5. **Launches Chrome**: With time manipulation active and the dashboard loaded

## Troubleshooting

### If something goes wrong:

**Problem: Script won't run**
- Make sure you're running `./launch-idrac.sh` 
- The script needs to be executable: `chmod +x launch-idrac.sh`

**Problem: No iDRAC servers found**
- The script scans your local network automatically
- You can manually navigate to your iDRAC IP in the opened Chrome window

**Problem: JNLP files don't work**
- First time: Configure Chrome to use the `jnlp-interceptor.sh` script
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