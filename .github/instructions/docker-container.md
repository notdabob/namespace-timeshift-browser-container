---
applyTo: 
  - "Dockerfile"
  - "docker/*.conf"
  - "docker/*.sh"
---

# Docker Container Development Instructions

## Container Architecture Best Practices

### Dockerfile Optimization
- Use multi-stage builds to reduce final image size
- Start with official Python slim base images for security and size
- Install system packages and clean up in single RUN layer
- Use specific package versions for reproducible builds
- Copy requirements.txt first for better Docker layer caching

### System Dependencies
- Install only essential packages: nginx, supervisor, openssh-client, nmap
- Use apt-get with --no-install-recommends to minimize package size
- Clean up package cache with `rm -rf /var/lib/apt/lists/*`
- Group related package installations in single RUN commands
- Pin important package versions for stability

### Service Management with Supervisor
- Configure each service (nginx, API, scanner) in supervisord.conf
- Use appropriate restart policies (always, on-failure)
- Configure log rotation and retention policies
- Set proper process priorities and resource limits
- Include stdout/stderr logging for debugging

### nginx Configuration
- Serve static content efficiently with appropriate caching headers
- Configure reverse proxy for API endpoints
- Use proper error pages and logging
- Enable gzip compression for text content
- Set security headers (X-Frame-Options, X-Content-Type-Options)

### Container Startup Process
- Create startup script that initializes required directories
- Set proper file permissions for web content and logs
- Initialize data files if they don't exist
- Validate configuration before starting services
- Implement graceful error handling for startup failures

### Security Configuration
- Run services with least privilege (www-data for nginx)
- Set proper file permissions (644 for files, 755 for directories)
- Disable unnecessary nginx modules and features
- Configure supervisor to run as non-root where possible
- Use proper secret management for sensitive configuration

### Data Persistence Strategy
- Store application data in `/app/www/data/` for volume mounting
- Keep logs in `/app/logs/` with rotation policies
- Store SSH keys in `/root/.ssh/` with proper permissions
- Separate configuration from application code
- Support data migration between container versions

### Health Monitoring
- Implement health check endpoint at `/health`
- Configure Docker HEALTHCHECK with appropriate intervals
- Monitor critical services (nginx, API, scanner) status
- Provide detailed status information for debugging
- Include startup time and dependency checks

### Resource Management
- Set appropriate memory limits for Python processes
- Configure nginx worker processes based on available CPU
- Use efficient logging to prevent disk space issues
- Monitor and limit network connections
- Implement proper cleanup for temporary files

### Port and Network Configuration
- Expose port 80 for web dashboard access
- Expose port 8765 for API server access
- Use host networking for network scanning capabilities
- Document all required network access patterns
- Support both bridge and host networking modes

### Development and Debugging Support
- Include development tools in debug build variants
- Provide shell access for troubleshooting
- Enable verbose logging modes for debugging
- Support configuration overrides via environment variables
- Include diagnostic commands and scripts

### Container Lifecycle Management
- Handle SIGTERM gracefully for clean shutdowns
- Implement proper service startup ordering
- Support configuration reloading without restart
- Provide backup and restore procedures
- Document update and migration procedures

### Performance Optimization
- Use nginx for static file serving instead of Python
- Optimize Python application startup time
- Configure appropriate buffer sizes and timeouts
- Enable efficient logging and log rotation
- Monitor resource usage and optimize accordingly

### Production Deployment Considerations
- Support running as non-root user where possible
- Include security scanning and vulnerability assessment
- Document required capabilities and privileges
- Provide resource requirement guidelines
- Support orchestration platforms (Docker Compose, Kubernetes)