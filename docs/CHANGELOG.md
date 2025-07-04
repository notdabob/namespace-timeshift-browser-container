# Changelog

All notable changes to this project will be documented in this file.

## [3.0.0] - 2025-07-04

### Major Features

- Multi-server type discovery support (iDRAC, Proxmox, Linux/SSH, Windows RDP, VNC)
- Remote Desktop Manager (RDM) export functionality in JSON and XML formats
- Custom network range scanning capability
- Enhanced dashboard with server type filtering
- Automatic server type detection and categorization

### Added

- `network-scanner.py`: Complete rewrite to support multiple server types
- `idrac-container-api.py`: New endpoints for RDM export and custom scanning
- `dashboard-generator.py`: Enhanced UI with tabs, export buttons, and custom scan input
- Server type icons and color coding in dashboard
- Support for Windows RDP (port 3389) and WinRM (port 5985)
- Support for VNC servers (ports 5900, 5901)
- Support for Proxmox VE servers (port 8006)
- Automatic SSH support detection for Linux servers
- RDM export with pre-configured connection settings per server type

### Changed

- Renamed from "iDRAC Management Container" to "Homelab Server Management Container"
- Updated all documentation to reflect multi-server capabilities
- Enhanced API to support new server types and export formats
- Improved network scanning with concurrent range support
- Updated SSH key deployment to work with all SSH-capable servers

### Technical

- Added `ipaddress` module for proper CIDR network handling
- Implemented server type detection logic based on port and service fingerprinting
- Added XML generation for RDM export format
- Backward compatibility maintained with legacy `discovered_idracs.json`

## [2.6.2] - 2025-07-02

### Fixed in v2.6.2 at 2025-07-02 15:23:48 EDT

- Corrected Proxmox VE detection path from `/etc/pve/version` to `/etc/pve/.version`
- Added additional verification using `pvesh` command availability
- Fixed deployment script failing on actual Proxmox VE hosts

## [2.6.1] - 2025-07-02

### Improved in v2.6.1 at 2025-07-02 14:47:21 EDT

- Replaced mermaid diagram with clean, readable ASCII tree structure in file-structure.md
- Enhanced shell alias script with better path handling and organization
- Fixed markdown linting issues in documentation files

### Documentation in v2.6.1 at 2025-07-02 14:47:21 EDT

- Added emojis for visual categorization in file-structure.md
- Expanded file purpose descriptions with detailed functionality
- Added container runtime structure visualization
- Improved data persistence documentation

## [2.6.0] - 2025-07-02

### Enhanced in v2.6.0 at 2025-07-02 14:22:33 EDT

- Documentation formatting improvements across README.md
- Enhanced PROXMOX-SETUP.md with clearer deployment instructions
- Updated CLAUDE.md with GitHub integration guidance
- Improved file-structure.md documentation reference patterns
- Better markdown formatting for lists and code blocks

### Changed in v2.6.0 at 2025-07-02 14:22:33 EDT

- Commit command to use timestamp-based section headers for changelog
- Documentation to emphasize file-structure.md as authoritative source
- Replaced unwieldy mermaid diagram with clean ASCII tree structure in file-structure.md
- Added Quick Overview section for better navigation of project structure

## [2.5.0] - 2025-07-02

### Added in v2.5.0

- Complete containerization with Docker support for Proxmox deployment
- Python-based API server for iDRAC management operations
- Dynamic HTML dashboard generator with real-time updates
- Network scanner module for automatic iDRAC discovery
- Proxmox deployment script with automated setup
- Container health checks and supervisor process management
- nginx web server configuration for static content serving

### Enhanced in v2.5.0

- Deployment script with improved IP detection and URL display
- User-friendly deployment output with clickable URLs
- Professional ASCII art deployment success messages
- Container management commands in deployment output
- Support for both HTTP dashboard (port 8080) and API (port 8765)

### Technical in v2.5.0

- Migrated from bash scripts to Python-based microservices architecture
- Implemented RESTful API endpoints for all iDRAC operations
- Docker multi-stage build for optimized container size
- Supervisor configuration for process management
- Persistent data volume support for configuration storage

### Removed in v2.5.0

- Legacy bash scripts (replaced by Python implementations):
  - src/jnlp-interceptor.sh
  - src/launch-idrac.sh
  - src/launch-timeshift-browser.sh
  - src/launch-virtual-console.sh

## [2.4.0] - 2025-07-02

### Changed in v2.4.0

- Remove deprecated VERSION file - use CHANGELOG.md as single source of truth for versions
- Update smart commit command documentation to reflect CHANGELOG-only versioning
- Simplify version management workflow

### Removed in v2.4.0

- `docs/VERSION` file (deprecated in favor of CHANGELOG.md versioning)

## [2.3.0] - 2025-07-02

### Added in v2.3.0

- Smart commit command system via `.claude/commands/commit.md`
- Claude Code project command `/project:commit` for version management
- Automated version increment detection (patch/minor/major)

### Enhanced in v2.3.0

- Documentation updated with smart commit workflow instructions
- README.md includes development workflow section
- CLAUDE.md expanded with detailed command usage examples

### Removed in v2.3.0

- Legacy `src/claude-commit.sh` script (migrated to Claude command)

## [2.2.0] - 2025-07-02

### Added in v2.2.0

- SSH key management system with email-based configuration
- Automated SSH key generation (RSA 4096-bit)
- SSH key deployment to all discovered servers
- SSH config file management with server aliases
- Admin configuration persistence in admin_config.json

### Enhanced in v2.2.0

- Dashboard now includes SSH key management interface
- Email input form for admin identification
- One-click SSH key generation and deployment scripts
- Passwordless SSH access via configured aliases

### Technical in v2.2.0

- New generate-ssh-key.command and deploy-ssh-keys.command scripts
- SSH config backup functionality
- Server alias format: idrac-192-168-1-23

## [2.1.0] - 2025-07-02

### Added in v2.1.0

- Initial project setup with automated dependency management
- Network discovery for iDRAC6 servers
- Time-shifted browser environment for expired SSL certificates
- Web dashboard with auto-generated server listings
- One-click .command file generation for easy access

### Infrastructure in v2.1.0

- Comprehensive script automation for all operations
- Proper file structure with src/, docs/, input/, output/ organization
- Git version control with structured commit workflow

## Version History

- **2.6.2** (2025-07-02): Fixed Proxmox VE detection path in deployment script
- **2.6.1** (2025-07-02): Improved file structure documentation and shell alias enhancements
- **2.6.0** (2025-07-02): Documentation enhancements and formatting improvements
- **2.5.0** (2025-07-02): Containerization and Python-based architecture for Proxmox deployment
- **2.4.0** (2025-07-02): Simplified version management using CHANGELOG.md
- **2.3.0** (2025-07-02): Smart commit command system
- **2.2.0** (2025-07-02): SSH key management and passwordless access
- **2.1.0** (2025-07-02): Initial comprehensive release
