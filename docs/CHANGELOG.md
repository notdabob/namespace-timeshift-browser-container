# Changelog

All notable changes to this project will be documented in this file.

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

- **2.2.0** (2025-07-02): SSH key management and passwordless access
- **2.1.0** (2025-07-02): Initial comprehensive release
