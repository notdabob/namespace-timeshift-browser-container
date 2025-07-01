# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS solution for accessing iDRAC6 servers with expired SSL certificates using time-shifted environments. The project creates isolated namespaces with manipulated system time to allow connections to legacy Dell iDRAC6 interfaces that have expired certificates.

## Key Components

- **time-shift-idrac.zsh**: Main script that creates isolated namespace with time manipulation
- **MacOS-faketime-browser.zsh**: Simple browser time-shifting example
- **viewer.jnlp**: iDRAC6 Virtual Console client configuration file

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

The main script creates a time-shifted environment where:

1. System time is set to 2020-01-01 12:00:00
2. Chrome launches with temporary profile
3. All child processes inherit the time shift
4. JNLP files can be handled with preserved time context
5. Environment cleans up automatically on exit

## Security Context

This tool is designed for legitimate network administration tasks to access legacy Dell iDRAC6 hardware that cannot be updated. The time manipulation is contained within isolated namespaces and does not affect the host system permanently.
