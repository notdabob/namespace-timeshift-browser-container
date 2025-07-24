---
applyTo: 
  - "src/idrac-container-api.py"
  - "src/idrac-api-server.py"
---

# Python API Development Instructions

## API Server Best Practices

### Flask Application Structure
- Use Flask factory pattern for large applications
- Implement proper error handlers for common HTTP status codes
- Use blueprints to organize routes by functionality
- Enable CORS for cross-origin requests if needed

### Request/Response Handling
- Always validate input parameters using request.json with proper error handling
- Return consistent JSON response format: `{"status": "success/error", "message": "...", "data": {...}}`
- Use appropriate HTTP status codes: 200 (success), 400 (bad request), 500 (server error)
- Implement request timeout handling for long-running operations

### SSH Key Management
- Generate RSA keys with minimum 2048-bit length (prefer 4096-bit)
- Store keys securely in `/root/.ssh/` directory within container
- Use paramiko for SSH operations with proper exception handling
- Implement connection timeout (10 seconds) for SSH operations
- Log all SSH key operations for security auditing

### Server Management Operations
- Validate server IP addresses before attempting connections
- Use threading for bulk operations across multiple servers
- Implement proper connection pooling for SSH connections
- Handle network timeouts gracefully with user-friendly error messages
- Support both password and key-based authentication

### Security Considerations
- Bind API server to localhost (127.0.0.1) for security
- Never log sensitive information like passwords or private keys
- Validate all file paths to prevent directory traversal attacks
- Use secure file permissions for SSH keys (600 for private keys)
- Implement rate limiting for key generation endpoints

### Error Handling and Logging
- Use proper logging with timestamps and severity levels
- Catch specific exceptions (paramiko.AuthenticationException, socket.timeout)
- Return informative error messages without exposing system details
- Log API endpoint access for monitoring and debugging
- Implement health check endpoints that return service status

### Configuration Management
- Read configuration from environment variables or JSON files
- Use default values with clear documentation
- Support runtime configuration updates where appropriate
- Store persistent data in mounted volumes, not container filesystem

### Performance Optimization
- Use connection pooling for database/file operations
- Implement proper caching for frequently accessed data
- Use async operations for network-intensive tasks
- Limit concurrent connections to prevent resource exhaustion
- Monitor memory usage for long-running processes

### API Endpoint Design
- Use RESTful URL patterns: `/api/v1/resource` 
- Implement proper HTTP method usage (GET, POST, PUT, DELETE)
- Support JSON request/response format primarily
- Include API version in URLs for future compatibility
- Provide comprehensive API documentation in docstrings