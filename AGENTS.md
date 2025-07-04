# AGENTS.md - Development Guide for AI Coding Agents

## Build/Test Commands
- **Container Build**: `docker build -t idrac-manager:latest .`
- **Deploy**: `./deploy-proxmox.sh deploy`
- **Test Python Syntax**: `python3 -m py_compile src/*.py`
- **Integration Testing**: `./test-multi-server.sh` (comprehensive multi-service test)
- **Run Single Service**: `python3 src/idrac-container-api.py` or `python3 src/network-scanner.py`
- **Container Logs**: `docker logs idrac-manager` or `./deploy-proxmox.sh logs`
- **Service Status**: `docker exec -it idrac-manager supervisorctl status`
- **API Testing**: `curl http://localhost:8765/status` (check API health)
- **Dashboard Testing**: `curl -s -o /dev/null -w "%{http_code}" http://localhost:8080` (check web interface)

## Code Style Guidelines
- **Language**: Python 3.11+ with Flask framework
- **Imports**: Standard library first, third-party, then local imports
- **Functions**: Use docstrings with triple quotes for all functions
- **Variables**: snake_case for variables/functions, UPPER_CASE for constants
- **Error Handling**: Use try/except blocks with specific exception types
- **Logging**: Use `log_message()` function with timestamps
- **File Paths**: Use `os.path.join()` for cross-platform compatibility
- **JSON**: Use `json.dump(data, f, indent=2)` for readable output
- **HTTP**: Use requests with `verify=False` for self-signed certificates
- **Threading**: Use threading.Lock() for shared data access
- **Configuration**: Store paths in constants at module top (DATA_DIR, etc.)
- **Environment Detection**: Check for Docker availability before running container commands
- **Script Permissions**: Ensure shell scripts are executable (`chmod +x script.sh`)
- **Color Output**: Use ANSI color codes for script output (GREEN, RED, YELLOW, NC)

## Testing Framework

This project uses integration testing rather than traditional unit tests:

### Integration Test Script (`test-multi-server.sh`)
- **Purpose**: Comprehensive testing of all container services
- **Coverage**: API endpoints, network scanner, dashboard, RDM export
- **Usage**: `./test-multi-server.sh` (requires running container)
- **Output**: Color-coded results with ✓/✗ indicators

### Test Categories
1. **Container Health**: Verify container is running and services are active
2. **API Testing**: Check `/status` endpoint and custom scan functionality
3. **Service Status**: Validate supervisorctl service states
4. **Dashboard Access**: HTTP status code verification
5. **Export Functions**: RDM JSON/XML endpoint testing
6. **Discovery Validation**: Check for discovered servers file

### Manual Testing Commands
- **API Health**: `curl http://localhost:8765/status | jq '.'`
- **Custom Scan**: `curl -X POST http://localhost:8765/scan/custom -H "Content-Type: application/json" -d '{"ranges": ["192.168.1.0/24"]}'`
- **Service Status**: `docker exec idrac-manager supervisorctl status`
- **Dashboard Check**: `curl -s -o /dev/null -w "%{http_code}" http://localhost:8080`

## Documentation Management Requirements

**CRITICAL**: Always update documentation in README.md and CLAUDE.md and update docs/CHANGELOG.md with version updates and keep current the docs/file-structure.md documentation files whenever changes are made to file or folder names, layout, purposes or a change in usage instructions to the user.

### Documentation Best Practices for Claude Code

- Use Markdown (`.md` files) for all primary project documentation, including `README.md`, installation guides, and general how-tos.
- Ensure Markdown files are clear, concise, and render well on GitHub and other code hosting platforms.
- Use Jupyter Notebooks (`.ipynb` files) only for interactive tutorials, code walkthroughs, or data-driven examples where executable code and output are needed.
- Link to Jupyter Notebooks from Markdown documentation when providing interactive or advanced examples.
- Do not use Jupyter Notebooks for static project documentation or main README files.
- Keep documentation up to date and ensure all code examples are tested and accurate.
- Prefer plain Markdown for compatibility and ease of collaboration.

### Jupyter Notebook Usage Guidelines for Claude Code

- When creating interactive tutorials, code walkthroughs, or step-by-step guides that benefit from live code execution and output, generate a Jupyter Notebook (`.ipynb` file) in addition to Markdown documentation.
- Jupyter Notebooks should:
  - Include clear Markdown cells explaining each step, command, or concept.
  - Provide code cells that users can execute directly to follow along with the tutorial or solution.
  - Show expected outputs or results where possible.
  - Be organized and easy to follow, with section headings and comments.
- For project-specific solutions (e.g., running scripts, deploying VMs, or configuring services), create a notebook that demonstrates the process interactively, allowing users to modify parameters and see results.
- Link to the generated Jupyter Notebook from the main documentation (e.g., `README.md`) so users can easily find and use the interactive guide.
- Ensure all code in notebooks is tested and works as intended in the project environment.
- Name notebooks descriptively (e.g., `interactive_vm_deployment_tutorial.ipynb`).
- Keep notebooks up to date with project changes and document any required dependencies or setup steps at the top of the notebook.

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

## File Structure Documentation Rule

- Do not prompt to update or modify `docs/file-structure.md` unless explicitly requested by the user.
- **No Type Hints**: This codebase doesn't use type annotations
- **Testing Approach**: Use integration testing via `test-multi-server.sh` rather than unit tests
- **Debug Mode**: Flask apps run with `debug=False` in production
- **Test Flags**: Some scripts support `--test` flag for dry-run operations