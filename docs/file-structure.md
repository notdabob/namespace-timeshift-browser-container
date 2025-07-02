# File Structure

## Quick Overview

This project is organized into the following key areas:

- **Application Code**: `/src` - Python services for API, scanning, and dashboard generation
- **Container Setup**: `/docker` - Configuration files for nginx, supervisor, and startup
- **Documentation**: `/docs` - Changelog, guides, and this file structure reference
- **Deployment**: Root-level scripts for easy Proxmox deployment

## Directory Structure

```text
namespace-timeshift-browser-container/
├── .claude/                      # Claude Code project commands
│   ├── commands/                 # Custom command definitions
│   │   └── commit.md            # Smart commit with version management
│   └── claude_command_setup.sh  # Command setup script
│
├── docker/                       # Container configuration files
│   ├── nginx.conf               # Web server configuration
│   ├── supervisord.conf         # Process management configuration
│   └── start.sh                 # Container startup script
│
├── docs/                         # Project documentation
│   ├── CHANGELOG.md             # Version history and changes
│   ├── file-structure.md        # This file - project organization
│   └── ProjectOverView.md       # Project overview documentation
│
├── src/                          # Application source code
│   ├── idrac-container-api.py   # REST API server for iDRAC operations
│   ├── idrac-api-server.py      # Alternative API server implementation
│   ├── network-scanner.py       # Network discovery service
│   ├── dashboard-generator.py   # Web dashboard generator
│   └── sync_shell_aliases.sh    # SSH alias management script
│
├── deploy-proxmox.sh            # Main deployment script for Proxmox
├── Dockerfile                   # Container build instructions
├── requirements.txt             # Python package dependencies
├── README.md                    # Project overview and quick start
├── PROXMOX-SETUP.md            # Detailed Proxmox deployment guide
├── DEPLOYMENT-SUMMARY.md       # Quick deployment reference
└── CLAUDE.md                   # Claude Code AI assistant instructions
```

## File Purposes by Category

### 🚀 Deployment & Container

- **deploy-proxmox.sh**: One-command deployment script that handles Docker installation, container building, and service startup
- **Dockerfile**: Multi-stage build configuration for optimized container size
- **requirements.txt**: Python dependencies (Flask, requests, paramiko, python-nmap)

### 🔧 Container Configuration (`/docker`)

- **nginx.conf**: Web server setup serving dashboard on port 80 and proxying API requests
- **supervisord.conf**: Manages multiple services (nginx, API, scanner) within the container
- **start.sh**: Initializes container environment and starts supervisor

### 💻 Application Services (`/src`)

- **idrac-container-api.py**: Main REST API providing endpoints for:
  - SSH key generation and deployment
  - Server status checking
  - Configuration management
- **network-scanner.py**: Background service that:
  - Scans network every 5 minutes
  - Discovers iDRAC servers
  - Updates JSON database
- **dashboard-generator.py**: Creates the web interface:

  - Reads discovered servers
  - Generates responsive HTML
  - Creates download scripts

- **idrac-api-server.py**: Alternative API implementation (development variant)
- **sync_shell_aliases.sh**: Manages SSH config file with server aliases

### 📚 Documentation (`/docs`)

- **CHANGELOG.md**: Version history with semantic versioning (single source of truth for versions)
- **file-structure.md**: This comprehensive guide to project organization
- **ProjectOverView.md**: Technical architecture and design decisions

### 🛠 Claude Code Integration (`.claude`)

- **commands/commit.md**: Smart commit command that:
  - Auto-detects version increments
  - Updates CHANGELOG.md
  - Maintains proper commit format
- **claude_command_setup.sh**: Configures Claude project commands

### 📖 Root Documentation

- **README.md**: Quick start guide with one-command deployment
- **PROXMOX-SETUP.md**: Comprehensive setup instructions and troubleshooting
- **DEPLOYMENT-SUMMARY.md**: Condensed deployment checklist
- **CLAUDE.md**: Guidelines for AI-assisted development

## Container Runtime Structure

When deployed, the container creates this internal structure:

```text
/app/                            # Container application root
├── www/                         # Web server document root
│   ├── index.html              # Generated dashboard (created by dashboard-generator.py)
│   ├── data/                   # JSON data files
│   │   ├── discovered_idracs.json    # Network scan results
│   │   └── admin_config.json         # SSH key configuration
│   └── downloads/              # Generated connection scripts
│
├── logs/                        # Application logs
│   ├── api.log                 # API server logs
│   ├── scanner.log             # Network scanner logs
│   └── dashboard.log           # Dashboard generator logs
│
└── src/                         # Mounted source code (from host)
```

## Data Persistence

The container maintains state through:

1. **Docker Volumes**

   - `idrac-data`: Persistent storage for discovered servers and configuration
   - Survives container restarts and updates

2. **Container Filesystem**

   - SSH keys in `/root/.ssh/`
   - Nginx and application logs

3. **Host Mounts**
   - Source code mounted read-only for easy updates

## Legacy Structure (Historical Reference)

The repository contains some legacy files from the macOS time-shift solution:

```text
output/                          # Not used in container deployment
├── tmp/                         # Old browser profiles
└── www/                         # Legacy generated files
```

These are excluded from the Docker build and will be removed in a future cleanup.

## Development Workflow

1. **Local Changes**: Edit files in your local clone
2. **Test**: Use `./deploy-proxmox.sh update` to rebuild container
3. **Version**: Use `/project:commit` for proper versioning
4. **Deploy**: Push to GitHub, then pull on Proxmox host
