# GitHub Copilot Instructions for iDRAC Management Container

This repository contains a containerized solution for managing Dell iDRAC servers and other server types through a professional web dashboard deployed on Proxmox. This document provides comprehensive guidance for GitHub Copilot when working with this codebase.

## Project Overview

**Purpose**: A Docker container that provides centralized management for multiple server types (iDRAC, Proxmox, Linux, Windows, VNC) through a browser-based dashboard, eliminating macOS quarantine issues and providing enterprise-ready server management.

**Architecture**: Multi-service container with nginx web server, Python Flask API, network discovery scanner, and dashboard generator.

**Target Deployment**: Proxmox VE hosts with Docker runtime for homelab and enterprise environments.

## Core Technologies

- **Container**: Docker with multi-service architecture using Supervisor
- **Backend**: Python 3.11 with Flask, requests, paramiko, python-nmap
- **Frontend**: HTML/CSS/JavaScript with responsive design
- **Web Server**: nginx with reverse proxy configuration
- **Process Management**: Supervisor for service orchestration
- **Network Discovery**: nmap-based scanning with multi-protocol detection

## Key Components and Their Purposes

### Container Infrastructure
- `Dockerfile`: Multi-stage build with system dependencies and Python services
- `docker/nginx.conf`: Web server config serving dashboard on port 80, API proxy
- `docker/supervisord.conf`: Process management for nginx, API, scanner services
- `docker/start.sh`: Container initialization and service startup

### Application Services (`src/`)
- `idrac-container-api.py`: Main REST API server for SSH key management, server operations
- `network-scanner.py`: Background discovery service scanning every 5 minutes
- `dashboard-generator.py`: Creates responsive web interface from discovered servers
- `init-data.py`: Initializes required JSON data files on container startup

### Deployment & Management
- `deploy-proxmox.sh`: One-command deployment script with Docker auto-install
- `test-multi-server.sh`: Testing script for verifying container functionality
- Emergency scripts: `emergency-fix.sh`, `container-rebuild.sh`, `restart-fix.sh`

## Code Style and Standards

### Python Code Guidelines
- Use Python 3.11+ features and syntax
- Follow PEP 8 style guide for formatting
- Use type hints where appropriate for function parameters and returns
- Include comprehensive docstrings for all classes and functions
- Use logging with timestamps instead of print statements
- Handle exceptions gracefully with specific error messages
- Use environment variables for configuration when possible

### API Development Standards
- Flask REST API patterns with proper HTTP status codes
- JSON responses with consistent error handling
- Validate input parameters and provide meaningful error messages
- Use paramiko for SSH operations with proper connection handling
- Implement health check endpoints for monitoring
- Follow RESTful URL patterns and HTTP methods

### Container Best Practices
- Multi-stage Docker builds for optimized image size
- Use official Python slim base images
- Install only required system packages and clean up in same layer
- Use supervisor for process management instead of custom init scripts
- Expose only necessary ports (80 for web, 8765 for API)
- Mount data volumes for persistence instead of container filesystem

### Security Considerations
- Default credentials are documented (root/calvin for iDRAC)
- SSH keys generated with RSA 4096-bit encryption
- API server bound to localhost for security
- Container runs with appropriate user permissions
- Network scanning respects timeouts and connection limits
- SSL verification disabled only for self-signed certificates with warnings

## Development Patterns

### Service Architecture
Each service should be self-contained with:
- Proper logging configuration
- Error handling and recovery
- Health check endpoints
- Graceful shutdown handling
- Configuration via environment variables or JSON files

### Data Management
- Use `/app/www/data/` for persistent JSON data files
- Server discovery data in `discovered_servers.json`
- Configuration data in `admin_config.json`
- Logs in `/app/logs/` with rotation
- SSH keys in container `/root/.ssh/`

### Network Operations
- Use connection timeouts (default 3 seconds)
- Implement proper retry mechanisms
- Handle network errors gracefully
- Support custom IP ranges via JSON configuration
- Multi-threaded scanning with worker limits (max 50)

## File Organization

### Documentation Structure
- `README.md`: User-facing deployment and usage guide
- `PROXMOX-SETUP.md`: Detailed setup instructions
- `CLAUDE.md`: AI assistant development guidance
- `docs/CHANGELOG.md`: Version history with semantic versioning
- `docs/file-structure.md`: Comprehensive project organization guide

### Source Code Organization
```
src/
├── idrac-container-api.py    # Main API server
├── network-scanner.py        # Discovery service
├── dashboard-generator.py    # Web interface generator
├── init-data.py             # Data initialization
└── sync_shell_aliases.sh    # SSH alias management
```

## API Endpoints and Functionality

### Core API Routes
- `GET /health` - Container health check
- `GET /status` - API server status and capabilities
- `POST /generate-ssh-key` - Generate RSA SSH key pair
- `POST /deploy-ssh-key` - Deploy keys to servers
- `POST /scan/custom` - Custom network range scanning
- `GET /api/export/rdm/{json|rdm}` - Remote Desktop Manager export

### Dashboard Features
- Auto-discovery every 5 minutes
- Real-time server status (online/offline)
- One-click connection scripts
- SSH key management interface
- Custom network range configuration
- Multi-server type support (iDRAC, Proxmox, Linux, Windows, VNC)

## Testing and Quality Assurance

### Testing Approach
- Use `test-multi-server.sh` for integration testing
- Test container build and deployment process
- Verify all API endpoints respond correctly
- Check network discovery functionality
- Validate SSH key generation and deployment

### Code Quality
- Python code should compile without syntax errors
- Handle all potential exceptions in network operations
- Use proper error codes and messages in API responses
- Implement logging for debugging and monitoring
- Follow container best practices for resource usage

## Common Development Tasks

### Adding New Server Types
1. Update `SERVER_TYPES` in `network-scanner.py` with ports and identifiers
2. Add detection logic for the new server type
3. Update dashboard template to handle new server type
4. Add appropriate connection scripts in download generation
5. Update documentation with new capabilities

### Modifying API Endpoints
1. Add route in `idrac-container-api.py`
2. Implement proper error handling and validation
3. Update API status endpoint capabilities list
4. Test endpoint functionality
5. Update dashboard if UI changes needed

### Container Configuration Changes
1. Update `Dockerfile` for new dependencies
2. Modify `supervisord.conf` for service changes
3. Test container build and startup
4. Update deployment scripts if needed
5. Document changes in CHANGELOG.md

## Version Management

Use semantic versioning (MAJOR.MINOR.PATCH):
- **PATCH**: Bug fixes, documentation updates, small improvements
- **MINOR**: New features, server types, significant enhancements  
- **MAJOR**: Breaking changes, architecture updates

Update `docs/CHANGELOG.md` with all changes and use the `/project:commit` Claude command for automated version management.

## Deployment Context

**Primary Use Case**: Proxmox homelab environments with multiple server types
**User Skill Level**: System administrators with basic Docker knowledge
**Network Environment**: Private networks with iDRAC and server management needs
**Access Pattern**: Web-based dashboard for multiple concurrent users

When suggesting code changes or new features, consider the production deployment context and maintain the balance between functionality and simplicity that makes this solution accessible to homelab administrators.