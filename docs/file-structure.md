# Project File Structure

```mermaid
graph TD
    A[time-shift-idrac/] --> B[scripts/]
    A --> C[docs/]
    A --> D[README.md]
    A --> E[viewer.jnlp]

    B --> F[time-shift-idrac.sh]
    B --> G[install-dependencies.sh]
    B --> H[java-time-wrapper.sh]
    B --> I[jnlp-time-interceptor.sh]
    B --> J[MacOS-faketime-browser.zsh]

    C --> K[ProjectOverView.md]
    C --> L[file-structure.md]

    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style F fill:#fff3e0
    style G fill:#fff3e0
    style H fill:#fff3e0
    style I fill:#fff3e0
    style J fill:#fff3e0
```

## File Descriptions

### Scripts Directory (`scripts/`)

- **time-shift-idrac.sh**: Main script that creates isolated namespace with time manipulation
- **install-dependencies.sh**: Dependency installation script for required tools
- **java-time-wrapper.sh**: Java wrapper that calculates time offset and launches Java with faketime
- **jnlp-time-interceptor.sh**: JNLP interceptor that handles Java Web Start with time manipulation
- **MacOS-faketime-browser.zsh**: Simple browser time-shifting example script

### Root Directory

- **README.md**: Installation instructions, usage workflow, and troubleshooting
- **viewer.jnlp**: iDRAC6 Virtual Console client configuration file

### Documentation Directory (`docs/`)

- **ProjectOverView.md**: Project requirements and technical specifications
- **file-structure.md**: This file - visual project structure diagram
