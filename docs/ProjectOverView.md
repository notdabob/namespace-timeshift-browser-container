# Create a macOS solution for accessing iDRAC6 with expired SSL certificates using a time-shifted environment

## The solution must include

1. A main script "scripts/time-shift-idrac.sh" that:

   - Creates an isolated namespace with unshare
   - Sets system time to 2020-01-01 12:00:00
   - Configures libfaketime for Java processes
   - Launches Firefox with a temporary profile
   - Handles JNLP files with faketime
   - Preserves time-shift for child Java processes
   - Provides user instructions in-terminal
   - Cleans up temporary files on exit

2. Dependency installation script "scripts/install-dependencies.sh" that:

   - Installs Homebrew (if not present)
   - Installs coreutils via Homebrew (provides `unshare` and `gdate`)
   - Installs libfaketime via Homebrew
   - Downloads Java faketime agent to /usr/local/lib/
   - Configures Firefox to handle JNLP files

3. Java wrapper "scripts/java-time-wrapper.sh" that:

   - Calculates time offset from real time
   - Launches Java with faketime JVM arguments
   - Preserves time-shift across JVM processes

4. JNLP interceptor "scripts/jnlp-time-interceptor.sh" that:

   - Accepts JNLP file path as argument
   - Launches javaws with explicit faketime
   - Integrates with Java Web Start

5. README.md with:
   - Installation instructions
   - Usage workflow
   - Verification commands
   - Troubleshooting tips

## Technical requirements

- Must work on macOS Ventura+
- Use unshare for namespace isolation
- Apply time shift to entire process tree
- Handle both browser and Java processes
- Support iDRAC6 Virtual Console (.jnlp)
- Include time verification commands
- Provide clear user instructions

## File structure

See [file-structure.md](file-structure.md) for a visual diagram of the project structure.
