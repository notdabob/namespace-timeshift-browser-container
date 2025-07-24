# Development Guide

This guide provides information for developers contributing to the iDRAC Management Container project.

## Development Environment Setup

### Prerequisites
- Python 3.11 or higher
- Docker and Docker Compose
- Git

### Local Development Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/notdabob/namespace-timeshift-browser-container.git
   cd namespace-timeshift-browser-container
   ```

2. **Install development dependencies**:
   ```bash
   # Install Python dependencies
   pip install -r requirements.txt
   
   # Install development tools
   pip install flake8 black isort pytest pytest-cov
   ```

3. **Install system dependencies** (for testing):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install nmap
   
   # macOS
   brew install nmap
   ```

## Code Quality Standards

### Python Code Style
This project follows PEP 8 standards with the following tools:

- **flake8**: Linting and style checking
- **black**: Code formatting (line length: 100)
- **isort**: Import sorting

### Running Code Quality Checks

```bash
# Format code with black
black src/

# Sort imports with isort
isort src/

# Lint with flake8
flake8 src/

# Run all checks
make lint  # (if Makefile exists) or run commands individually
```

## Testing

### Test Structure
- `tests/` - Unit and integration tests
- `test_basic.py` - Basic functionality tests
- Test files follow `test_*.py` naming convention

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/test_basic.py -v

# Run tests and open coverage report
pytest --cov=src --cov-report=html && open htmlcov/index.html
```

### Writing Tests
- Use Python's `unittest` framework
- Mock external dependencies (network calls, file systems)
- Test both success and failure cases
- Aim for high code coverage (>80%)

## Container Development

### Building and Testing Locally

```bash
# Build the container
docker build -t idrac-manager:dev .

# Run for testing
docker run -d --name idrac-test -p 8080:80 -p 8765:8765 idrac-manager:dev

# Check logs
docker logs idrac-test

# Test endpoints
curl http://localhost:8080/health
curl http://localhost:8765/status

# Clean up
docker stop idrac-test && docker rm idrac-test
```

### Container Development Workflow

1. **Make code changes** in `src/` directory
2. **Test locally** with Python interpreter
3. **Build container** to test integration
4. **Run container tests** to verify functionality
5. **Commit changes** with proper messages

## API Development

### Adding New Endpoints

1. **Define the endpoint** in `src/idrac-container-api.py`:
   ```python
   @app.route('/api/new-feature', methods=['POST'])
   def new_feature():
       try:
           # Validate input
           data = request.get_json()
           if not data:
               return jsonify({'error': 'Invalid JSON'}), 400
           
           # Implement functionality
           result = process_new_feature(data)
           
           return jsonify({'status': 'success', 'data': result})
       except Exception as e:
           return jsonify({'error': str(e)}), 500
   ```

2. **Add tests** for the new endpoint
3. **Update API documentation** in docstrings
4. **Test with curl or Postman**

### Error Handling Standards
- Always return JSON responses
- Use appropriate HTTP status codes
- Include error messages that help users
- Log errors for debugging
- Handle network timeouts gracefully

## Network Scanner Development

### Adding New Server Types

1. **Update SERVER_TYPES** in `src/network-scanner.py`:
   ```python
   'new_type': {
       'ports': [1234, 5678],
       'identifiers': ['service-name', 'identifier'],
       'default_credentials': {'username': 'admin', 'password': ''},
       'description': 'New Server Type'
   }
   ```

2. **Add detection logic** for the new server type
3. **Update dashboard** to handle new server type
4. **Test discovery** with real servers when possible

## Documentation Standards

### Code Documentation
- Add docstrings to all functions and classes
- Use type hints where appropriate
- Include usage examples in docstrings
- Document any complex algorithms or business logic

### User Documentation
- Update README.md for user-facing changes
- Update PROXMOX-SETUP.md for deployment changes
- Keep CHANGELOG.md current with all changes
- Use clear, actionable language

## Git Workflow

### Branching Strategy
- `main` - Stable, deployable code
- `develop` - Integration branch for features
- `feature/description` - Feature development branches
- `bugfix/description` - Bug fix branches

### Commit Message Format
```
type(scope): brief description

Longer description if needed

- List specific changes
- Include breaking changes
- Reference issues: Fixes #123
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Pull Request Process
1. Create feature branch from `develop`
2. Make changes with tests
3. Ensure all CI checks pass
4. Update documentation
5. Submit PR with description
6. Address review feedback
7. Merge after approval

## Continuous Integration

### GitHub Actions
The project uses GitHub Actions for:
- **Code Quality**: flake8, black, isort checks
- **Testing**: pytest with coverage reporting
- **Container Build**: Docker build and basic testing
- **Multi-Python**: Testing on Python 3.11 and 3.12

### Local CI Simulation
```bash
# Run the same checks as CI
flake8 src/ --count --select=E9,F63,F7,F82 --show-source --statistics
black --check src/
isort --check-only src/
pytest tests/ -v --cov=src
docker build -t idrac-manager:test .
```

## Performance Considerations

### Python Code
- Use connection pooling for network operations
- Implement proper timeouts (3 seconds for scans)
- Limit concurrent operations (max 50 workers)
- Use efficient data structures
- Monitor memory usage for long-running processes

### Container Optimization
- Multi-stage Docker builds
- Minimal base images
- Layer caching optimization
- Health checks for monitoring
- Resource limits in production

## Security Guidelines

### Code Security
- Validate all user inputs
- Use parameterized queries/commands
- Handle sensitive data appropriately
- Follow principle of least privilege
- Log security-relevant events

### Container Security
- Run services as non-root when possible
- Use specific user IDs
- Limit container capabilities
- Scan for vulnerabilities
- Update base images regularly

## Troubleshooting Development Issues

### Common Problems

1. **Import errors**: Check Python path and virtual environment
2. **Network scanner fails**: Verify nmap installation and permissions
3. **Container won't start**: Check Docker logs and supervisor status
4. **Tests fail**: Ensure all dependencies are installed
5. **Linting errors**: Run black and isort to fix formatting

### Debug Mode
Enable debug logging by setting environment variables:
```bash
export DEBUG=1
export FLASK_ENV=development
python src/idrac-container-api.py
```

## Getting Help

- **Documentation**: Check README.md and docs/ directory
- **Issues**: Create GitHub issue with reproduction steps
- **Discussions**: Use GitHub Discussions for questions
- **Code Review**: Request reviews on pull requests

## Contributing Guidelines

1. **Follow code standards** (PEP 8, type hints, docstrings)
2. **Write tests** for new functionality
3. **Update documentation** for user-facing changes
4. **Test thoroughly** including edge cases
5. **Keep changes focused** (one feature per PR)
6. **Be responsive** to review feedback