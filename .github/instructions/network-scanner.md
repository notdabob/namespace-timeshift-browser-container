---
applyTo: 
  - "src/network-scanner.py"
---

# Network Scanner Development Instructions

## Network Discovery Best Practices

### Scanning Strategy
- Use nmap for efficient network discovery with appropriate scan types
- Implement multi-threaded scanning with configurable worker limits (default: 50)
- Use connection timeouts (3 seconds) to prevent hanging on unreachable hosts
- Support both CIDR notation (192.168.1.0/24) and IP ranges (192.168.1.1-254)
- Scan only common service ports to reduce scan time and network load

### Server Type Detection
- Define server types with port patterns and service identifiers
- Use HTTP headers and response content for service identification
- Support SSL/TLS connections with certificate verification disabled for self-signed certs
- Implement fallback detection methods for servers with non-standard configurations
- Cache detection results to avoid redundant scans

### Supported Server Types
```python
SERVER_TYPES = {
    'idrac': {'ports': [443, 80], 'identifiers': ['idrac', 'dell']},
    'proxmox': {'ports': [8006], 'identifiers': ['proxmox', 'pve']},
    'linux': {'ports': [22], 'identifiers': ['ssh', 'openssh']},
    'windows': {'ports': [3389, 5985], 'identifiers': ['rdp', 'winrm']},
    'vnc': {'ports': [5900, 5901], 'identifiers': ['vnc', 'realvnc']}
}
```

### Data Management
- Store scan results in JSON format in `/app/www/data/discovered_servers.json`
- Include timestamp, server type, status, and connection details
- Maintain server history to track availability changes
- Support custom network ranges from `custom_ranges.json` configuration
- Implement atomic file writes to prevent corruption during updates

### Error Handling
- Handle network timeouts gracefully without stopping the scan
- Log scan progress and errors for debugging
- Continue scanning other targets when individual hosts fail
- Implement retry logic for temporarily unreachable servers
- Validate IP addresses and network ranges before scanning

### Performance Optimization
- Use threading.ThreadPoolExecutor for concurrent scanning
- Limit concurrent connections to prevent network flooding
- Implement scan scheduling to avoid continuous high network usage
- Use efficient data structures for storing scan results
- Monitor memory usage for large network scans

### Configuration Support
- Read custom network ranges from JSON configuration files
- Support runtime configuration updates without restart
- Allow scan interval customization (default: 5 minutes)
- Support inclusion/exclusion lists for IP ranges
- Enable/disable specific server type detection

### Integration with Container
- Run as background service managed by supervisor
- Provide health check endpoint for monitoring
- Generate appropriate exit codes for supervisor restart policies
- Support graceful shutdown on container stop signals
- Write status information for dashboard consumption

### Security Considerations
- Respect network scanning etiquette and rate limits
- Only scan networks you have permission to scan
- Use least privilege approach for network access
- Log scanning activities for security auditing
- Avoid scanning external/internet IP ranges

### Monitoring and Debugging
- Log scan progress with timestamps and target counts
- Report scan duration and discovered server counts
- Provide verbose logging mode for troubleshooting
- Generate scan reports for network administrators
- Support manual scan triggers via API endpoints