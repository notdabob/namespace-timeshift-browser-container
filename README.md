# Homelab Server Management Container

A containerized solution for managing multiple server types (iDRAC, Proxmox, Linux, Windows, VNC) through a professional web dashboard deployed on Proxmox.

## Overview

This solution provides centralized server management through a Docker container that runs on your Proxmox host. It automatically discovers and manages various server types in your homelab, eliminates access issues, and offers a professional web-based management interface with Remote Desktop Manager integration.

**Key Benefits:**

- 🌐 **Access from any device** - Web dashboard works on phones, tablets, laptops
- 🚫 **No macOS quarantine issues** - Everything is browser-based
- 🔍 **Multi-server auto-discovery** - Finds iDRAC, Proxmox, Linux, Windows, and VNC servers
- 🔑 **SSH key management** - Generate and deploy keys with one click
- 🖥️ **One-click connections** - Launch appropriate client for each server type
- 📤 **RDM Export** - Export to Remote Desktop Manager (JSON/XML formats)
- 🎯 **Custom network scanning** - Scan specific network ranges on demand
- 🐳 **Enterprise-ready** - Container-based deployment

## 🚀 Quick Deployment

### Prerequisites

- Proxmox VE 7.0 or later
- Root access to Proxmox host
- Git installed on Proxmox host (`apt update && apt install git`)
- Network connectivity to iDRAC servers

### One-Command Deployment

**If you need to SSH to Proxmox first:**

```bash
# 1. SSH to your Proxmox host
ssh root@your-proxmox-host

# 2. Clone the repository
git clone https://github.com/notdabob/namespace-timeshift-browser-container.git
cd namespace-timeshift-browser-container

# 3. Deploy the container
chmod +x deploy-proxmox.sh
./deploy-proxmox.sh deploy
```

**If you're already on your Proxmox shell:**

```bash
# Clone and deploy in one go
git clone https://github.com/notdabob/namespace-timeshift-browser-container.git && \
cd namespace-timeshift-browser-container && \
chmod +x deploy-proxmox.sh && \
./deploy-proxmox.sh deploy
```

The deployment script will automatically detect your Proxmox host IP and provide you with a clickable dashboard URL when deployment completes.

That's it! The container will automatically:

- ✅ Install Docker if needed
- ✅ Build the multi-server management container
- ✅ Start all services (web server, API, network scanner)
- ✅ Begin discovering all server types on your network
- ✅ Provide a web dashboard for unified management

## Dashboard Features

### 📊 Multi-Server Management

- **Auto-discovery**: Scans network every 5 minutes for all server types
- **Server types**: iDRAC, Proxmox, Linux/SSH, Windows RDP, VNC
- **Status monitoring**: Real-time online/offline status for all servers
- **One-click access**: Appropriate connection method for each server type
- **Custom scanning**: Add specific network ranges to discover
- **Remote Desktop Manager export**: Export all servers to RDM (JSON/XML)

### 🔐 SSH Key Management

- **Generate SSH keys**: RSA 4096-bit with email identification
- **Deploy to servers**: One-click deployment to all SSH-capable servers
- **Passwordless access**: SSH directly using auto-configured aliases
- **Secure storage**: Keys stored safely within container
- **Multi-server support**: Works with iDRAC, Linux, and any SSH server

### 🌐 Network-Wide Access

- **Any device**: Access from computers, phones, tablets
- **Professional UI**: Clean, responsive web interface
- **Real-time updates**: Dashboard refreshes automatically
- **Multi-user ready**: Multiple people can access simultaneously

### 📤 Remote Desktop Manager Integration

- **Export formats**: JSON and XML (.rdm) supported
- **Auto-configured connections**: Each server type properly configured
- **Credential templates**: Default usernames included
- **Group organization**: All servers grouped under "Homelab Servers"
- **One-click import**: Import directly into RDM

## Default Credentials

**iDRAC Access:**

- Username: `root`
- Password: `calvin`

These are the standard Dell iDRAC6 factory defaults.

## Container Management

### Status and Monitoring

```bash
# Check container status


# View real-time logs
./deploy-proxmox.sh logs

# Check Docker container directly
docker ps | grep idrac-manager
docker logs idrac-manager
```

### Updates and Maintenance

```bash
# Update to latest version from GitHub
git pull origin main
./deploy-proxmox.sh update

# Restart container
docker restart idrac-manager

# Stop container
docker stop idrac-manager

# Remove everything (with confirmation)
./deploy-proxmox.sh cleanup
```

## File Structure

```text
namespace-timeshift-browser-container/
├── 🐳 Container Components
│   ├── Dockerfile                         # Multi-service container definition
│   ├── requirements.txt                   # Python dependencies
│   ├── deploy-proxmox.sh                  # One-command deployment script
│   └── docker/
│       ├── nginx.conf                     # Web server configuration
│       ├── supervisord.conf               # Service management
│       └── start.sh                       # Container startup script
│
├── 🚀 Application Services
│   └── src/
│       ├── idrac-container-api.py         # REST API server
│       ├── network-scanner.py             # Auto-discovery service
│       └── dashboard-generator.py         # Web interface generator
│
├── 📚 Documentation
│   ├── README.md                          # This file
│   ├── PROXMOX-SETUP.md                   # Detailed setup guide
│   ├── DEPLOYMENT-SUMMARY.md              # Quick reference
│   └── docs/                              # Additional documentation
│
└── 🔧 Development
    ├── .claude/commands/                   # Claude Code commands
    ├── CLAUDE.md                          # Development guidance
    └── .gitignore                         # Version control exclusions
```

## How It Works

### Container Architecture

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
│           Exposed Ports             │
│       8080 (Web) | 8765 (API)      │
└─────────────────────────────────────┘
```

### Service Components

1. **nginx Web Server** - Serves dashboard and handles routing
2. **Python API Server** - Manages SSH keys, server operations
3. **Network Scanner** - Discovers iDRAC servers automatically
4. **Dashboard Generator** - Creates responsive web interface
5. **Supervisor** - Manages all services within container

## Troubleshooting

### Container Won't Start

```bash
# Check logs for errors
docker logs idrac-manager

# Verify system resources
docker system df
df -h

# Restart Docker service
systemctl restart docker
```

### No Servers Discovered

```bash
# Test network scanning manually
docker exec -it idrac-manager python3 /app/src/network-scanner.py

# Check container network connectivity
docker exec -it idrac-manager ping 192.168.1.1

# Verify network range in scanner
docker exec -it idrac-manager cat /app/src/network-scanner.py
```

### Dashboard Not Loading

```bash
# Check nginx status
docker exec -it idrac-manager nginx -t

# Test API server
curl http://localhost:8765/status

# Check all services
docker exec -it idrac-manager supervisorctl status
```

### SSH Key Deployment Fails

```bash
# Test SSH connectivity to iDRAC
docker exec -it idrac-manager ssh -o ConnectTimeout=10 root@idrac-ip

# Check iDRAC SSH settings (Enable SSH in iDRAC web interface)
# Navigate: iDRAC Settings → Network → Services → SSH
```

### For deployment issues

1. **Check container logs**: `docker logs idrac-manager`
2. **Verify network connectivity**: Test access to iDRAC servers
3. **Review system resources**: Ensure adequate CPU/memory
4. **Check service status**: `docker exec -it idrac-manager supervisorctl status`
5. **Update to latest**: `git pull && ./deploy-proxmox.sh update`

## Comparison: Container vs macOS Solution

| Feature               | macOS Time-Shift     | Container Solution   |
| --------------------- | -------------------- | -------------------- |
| **Deployment**        | Complex setup        | One command          |
| **Access**            | Single Mac only      | Network-wide         |
| **Quarantine Issues** | ❌ Constant problems | ✅ None              |
| **Time Manipulation** | ❌ Required          | ✅ Not needed        |
| **Professional Use**  | ❌ Dev tool          | ✅ Enterprise ready  |
| **Multi-user**        | ❌ Single user       | ✅ Concurrent access |
| **Maintenance**       | ❌ Manual updates    | ✅ Container updates |

## Advanced Configuration

### Custom Network Scanning

```bash
# Edit scanner for custom IP ranges
docker exec -it idrac-manager vi /app/src/network-scanner.py
docker restart idrac-manager
```

### Custom Ports

Edit `deploy-proxmox.sh` before deployment:

```bash
HTTP_PORT="8080"    # Web dashboard port
API_PORT="8765"     # API server port
```

### Backup and Restore

```bash
# Backup container data
docker run --rm -v idrac-data:/data -v $(pwd):/backup ubuntu tar czf /backup/idrac-backup.tar.gz -C /data .

# Restore container data
docker run --rm -v idrac-data:/data -v $(pwd):/backup ubuntu tar xzf /backup/idrac-backup.tar.gz -C /data
```

## Security Considerations

- **Network Access**: Container requires host networking (`--network host`) for iDRAC discovery, or ensure appropriate ports are mapped if using bridge mode
- **API Security**: API server is bound to localhost (127.0.0.1) and only accessible from the Proxmox host; if configured to bind to all interfaces, access is restricted by firewall rules.
- **Default Credentials**: **You MUST change default iDRAC passwords after setup to prevent unauthorized access.**
- **Data Persistence**: All data stored in Docker volumes
- **Container Isolation**: All services run within Docker container boundaries
- **Data Persistence**: Sensitive data stored in Docker volumes, not in git
- **SSH Key Security**: Keys generated and stored securely within container
- **Access Control**: Web dashboard provides read-only server information to users, while management actions (such as SSH key deployment) are available to authorized users

## Development Workflow

### Container Development

1. **Edit source files**: Modify Python services in `src/`
2. **Update container**: Run `./deploy-proxmox.sh update`
3. **Test changes**: Access dashboard and verify functionality
4. **Commit changes**: Use `/project:commit` for version management

### Local Testing

```bash
# Build container locally
docker build -t idrac-manager:test .

# Run for testing
docker run -d --name test-container -p 8080:80 -p 8765:8765 idrac-manager:test

# Check logs
docker logs test-container

# Clean up
docker stop test-container && docker rm test-container
```

### Smart Commit Command

This project includes a custom Claude Code command for version management:

```bash
/project:commit                    # Auto-detect changes and commit
/project:commit minor             # Force minor version bump
/project:commit -m "Fix" patch    # Custom message with patch version
```

The command automatically:

- Analyzes file changes for appropriate version increment
- Updates CHANGELOG.md with version entries
- Creates properly formatted git commits
- Includes Claude Code attribution

## GitHub Repository

**Source Code**: <https://github.com/notdabob/namespace-timeshift-browser-container>

### Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit with descriptive messages: `git commit -m "Add feature description"`
5. Push to your fork: `git push origin feature-name`
6. Create a Pull Request

### Issues and Support

- **Bug Reports**: [Create an issue](https://github.com/notdabob/namespace-timeshift-browser-container/issues) on GitHub
- **Feature Requests**: [Open a feature request](https://github.com/notdabob/namespace-timeshift-browser-container/issues) with detailed requirements
- **Questions**: Check existing [discussions](https://github.com/notdabob/namespace-timeshift-browser-container/discussions) or start a new one

## Deployment Architecture

### Proxmox Integration

```text
Proxmox Host
├── Docker Engine
└── Container (idrac-manager)
    ├── Port 8080 ──► External Web Access
    ├── Port 8765 ──► Internal API (localhost only)
    └── Volume ─────► Persistent Data Storage
```

### Network Requirements

- **Host Network Access**: Container needs access to iDRAC servers on ports 80/443/22
- **External Access**: Users access web dashboard via Proxmox host IP on port 8080
- **Internal API**: API server only accessible from Proxmox host for security

## License

This tool is designed for legitimate network administration tasks to access Dell iDRAC hardware in enterprise environments.
This architecture provides a professional, enterprise-ready solution that completely eliminates macOS-specific issues while offering superior functionality and accessibility.
