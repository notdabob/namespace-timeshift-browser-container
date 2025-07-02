# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a containerized solution for managing Dell iDRAC servers through a professional web dashboard deployed on Proxmox. The project eliminates macOS quarantine issues by providing a centralized, browser-based management interface that runs as a Docker container.

## Key Components

### Container Infrastructure

- **Dockerfile**: Multi-service container with nginx, Python API, and network scanner
- **deploy-proxmox.sh**: One-command deployment script for Proxmox hosts
- **docker/**: Container configuration files (nginx.conf, supervisord.conf, start.sh)
- **requirements.txt**: Python dependencies for container services

### Application Services

- **idrac-container-api.py**: REST API server for SSH key management and server operations
- **network-scanner.py**: Automated iDRAC discovery service that scans every 5 minutes
- **dashboard-generator.py**: Creates responsive web interface for server management

### Documentation

- **README.md**: Main documentation with deployment instructions
- **PROXMOX-SETUP.md**: Detailed setup guide and troubleshooting
- **DEPLOYMENT-SUMMARY.md**: Quick reference for deployment

## Core Architecture

The solution uses a multi-service Docker container architecture:

1. **Container Host**: Proxmox VE server with Docker runtime
2. **Web Server**: nginx serving dashboard on port 8080
3. **API Server**: Python Flask API on port 8765 for management operations
4. **Network Discovery**: Background service scanning for iDRAC servers
5. **Data Persistence**: Docker volumes for server database and SSH keys

### Service Architecture

```text
┌─────────────────────────────────────┐
│ Proxmox Host                        │
│ ┌─────────────────────────────────┐ │
│ │ iDRAC Manager Container         │ │
│ │ ┌─────────────┐ ┌─────────────┐ │ │
│ │ │ nginx       │ │ Python API  │ │ │
│ │ │ (Port 80)   │ │ (Port 8765) │ │ │
│ │ └─────────────┘ └─────────────┘ │ │
│ │ ┌─────────────┐ ┌─────────────┐ │ │
│ │ │ Dashboard   │ │ Network     │ │ │
│ │ │ Generator   │ │ Scanner     │ │ │
│ │ └─────────────┘ └─────────────┘ │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Dependencies

The container automatically installs and manages all dependencies:

### System Dependencies (via apt)

- `openssh-client` (SSH key management)
- `nmap` (network scanning)
- `curl`, `jq` (HTTP requests and JSON processing)
- `nginx` (web server)
- `supervisor` (service management)

### Python Dependencies (via pip)

- `flask` (API server framework)
- `requests` (HTTP client)
- `paramiko` (SSH operations)
- `python-nmap` (network scanning)

### Runtime Environment

- Python 3.11
- Docker container runtime
- Proxmox VE host system

## Usage Pattern

The deployment follows a simple git-based pattern:

1. **Clone Repository**: `git clone` from GitHub to Proxmox host
2. **Deploy Container**: Run `./deploy-proxmox.sh deploy`
3. **Access Dashboard**: Browse to `http://proxmox-ip:8080`
4. **Automatic Operations**: Container handles discovery, SSH keys, and management

### Primary Deployment Workflow

```bash
# SSH to Proxmox host
ssh root@proxmox-host

# Clone repository from GitHub
git clone https://github.com/notdabob/namespace-timeshift-browser-container.git
cd namespace-timeshift-browser-container

# Deploy container
./deploy-proxmox.sh deploy

# Access via browser
http://PROXMOX-IP:8080
```

### Container Management

```bash
# Status monitoring
./deploy-proxmox.sh status
./deploy-proxmox.sh logs

# Maintenance
./deploy-proxmox.sh update
./deploy-proxmox.sh cleanup

# Direct Docker commands
docker ps | grep idrac-manager
docker logs idrac-manager
docker exec -it idrac-manager bash
```

## Common Development Commands

### Container Deployment

```bash
# Full deployment (installs Docker if needed)
./deploy-proxmox.sh deploy

# Check deployment status
./deploy-proxmox.sh status

# View real-time logs
./deploy-proxmox.sh logs
```

### Container Development

```bash
# Build container image
docker build -t idrac-manager:latest .

# Run container manually for testing
docker run -d --name idrac-test -p 8080:80 -p 8765:8765 idrac-manager:latest

# Enter container for debugging
docker exec -it idrac-manager bash

# Check service status within container
docker exec -it idrac-manager supervisorctl status
```

### API Testing

```bash
# Test API server status
curl http://localhost:8765/status

# Test network scanner manually
docker exec -it idrac-manager python3 /app/src/network-scanner.py

# Check discovered servers
curl http://localhost:8080/data/discovered_idracs.json
```

### Service Management

```bash
# Restart all services
docker restart idrac-manager

# Restart specific service within container
docker exec -it idrac-manager supervisorctl restart idrac-api
docker exec -it idrac-manager supervisorctl restart network-scanner

# Check nginx configuration
docker exec -it idrac-manager nginx -t
```

## Development Notes

### Container Architecture

The solution uses a single container with multiple services managed by Supervisor:

- **nginx**: Web server and reverse proxy
- **idrac-api**: Python Flask API server
- **network-scanner**: Background discovery service
- **cron**: Scheduled tasks

### Generated Files

The container automatically generates files in `/app/www/`:

- `/app/www/index.html`: Main dashboard interface
- `/app/www/data/discovered_idracs.json`: Server database
- `/app/www/data/admin_config.json`: SSH key configuration
- `/app/www/downloads/`: Connection scripts for users

### Data Persistence

All persistent data is stored in Docker volumes:

- **idrac-data**: Server database and configuration
- **SSH keys**: Stored in `/root/.ssh/` within container
- **Logs**: Available via `docker logs` and `/app/logs/`

### Network Requirements

The container requires network access to:

- iDRAC servers on ports 80/443 (discovery and web access)
- iDRAC servers on port 22 (SSH key deployment)
- Internet access for package installation (during build)

### File Organization

**IMPORTANT**: For complete file structure details, always reference the docs/file-structure.md as the authoritative source of project organization.

- **Container files**: `Dockerfile`, `requirements.txt`, `docker/`
- **Application services**: `src/idrac-container-api.py`, `src/network-scanner.py`, `src/dashboard-generator.py`
- **Documentation**: `README.md`, `PROXMOX-SETUP.md`, `DEPLOYMENT-SUMMARY.md`
- **Legacy files**: Old macOS scripts are deprecated and excluded from container builds

### Security Considerations

- **Container Isolation**: All services run within Docker container
- **Network Security**: API server only accessible from Proxmox host
- **SSH Key Security**: Keys stored securely within container filesystem
- **Default Credentials**: Standard iDRAC defaults (root/calvin)

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
- **Version Management**: Updates CHANGELOG.md automatically
- **Smart Messages**: Generates contextual commit messages based on changes
- **Claude Attribution**: Includes proper Claude Code attribution in commits

**Version Increment Rules:**

- `patch`: Bug fixes, documentation updates, small improvements
- `minor`: New features, script additions, significant enhancements
- `major`: Breaking changes, major architectural updates

## Troubleshooting Common Issues

### Container Won't Start

```bash
# Check system resources
docker system df
df -h

# Verify Docker is running
systemctl status docker

# Check container logs
docker logs idrac-manager
```

### Network Discovery Issues

```bash
# Test network scanning manually
docker exec -it idrac-manager python3 /app/src/network-scanner.py

# Check container network connectivity
docker exec -it idrac-manager ping 192.168.1.1

# Verify port accessibility
docker exec -it idrac-manager nmap -p 80,443 192.168.1.1-254
```

### Dashboard Access Issues

```bash
# Check nginx status
docker exec -it idrac-manager nginx -t
docker exec -it idrac-manager supervisorctl status nginx

# Test API server
curl http://localhost:8765/status

# Check file permissions
docker exec -it idrac-manager ls -la /app/www/
```

### SSH Key Management Issues

```bash
# Test SSH connectivity
docker exec -it idrac-manager ssh -o ConnectTimeout=10 root@idrac-ip

# Check SSH key files
docker exec -it idrac-manager ls -la /root/.ssh/

# Verify SSH service on iDRAC
# Enable SSH in iDRAC web interface: iDRAC Settings → Network → Services → SSH
```

## Migration from Legacy macOS Solution

If migrating from the previous macOS time-shifting solution:

1. **No Time Manipulation**: Container solution works with current SSL certificates
2. **No Local Dependencies**: No need for Homebrew, libfaketime, or Chrome
3. **Centralized Access**: Replace local .command files with web dashboard
4. **SSH Key Migration**: Transfer existing SSH keys to container if needed

The container solution completely eliminates the macOS quarantine problem by providing browser-based access instead of downloadable files.

## GitHub Integration

**Repository**: <https://github.com/notdabob/namespace-timeshift-browser-container>

### Development Workflow with GitHub

1. **Clone repository**: `git clone https://github.com/notdabob/namespace-timeshift-browser-container.git`
2. **Create feature branch**: `git checkout -b feature-name`
3. **Make changes**: Edit source files and test locally
4. **Test deployment**: Use `./deploy-proxmox.sh update` to test changes
5. **Commit changes**: Use `/project:commit` for proper versioning
6. **Push and create PR**: `git push origin feature-name` then create Pull Request
7. **Merge to main**: After review, merge PR to main branch
8. **Deploy updates**: Users run `git pull && ./deploy-proxmox.sh update`

### Version Management

The project uses semantic versioning managed through:

- **CHANGELOG.md**: Tracks all version changes and features
- **Git tags**: Release versions are tagged in Git
- **Claude Commands**: `/project:commit` automates version bumps

### Repository Structure for GitHub

- **main branch**: Stable, deployable code
- **feature branches**: Development work
- **releases**: Tagged versions for stable deployments
- **issues**: Bug reports and feature requests
- **discussions**: Community Q&A and support
