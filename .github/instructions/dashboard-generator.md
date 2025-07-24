---
applyTo: 
  - "src/dashboard-generator.py"
---

# Dashboard Generator Development Instructions

## Web Interface Generation Best Practices

### HTML Generation
- Generate responsive HTML with mobile-first design principles
- Use semantic HTML5 elements for accessibility
- Include proper meta tags for viewport and charset
- Generate clean, well-indented HTML for maintainability
- Support modern browsers with graceful degradation

### CSS Framework Integration
- Use CSS Grid and Flexbox for responsive layouts
- Implement CSS custom properties (variables) for theming
- Include dark/light mode support with user preference detection
- Use progressive enhancement for advanced CSS features
- Optimize CSS for fast loading and rendering

### JavaScript Functionality
- Use vanilla JavaScript for maximum compatibility
- Implement proper error handling for all API calls
- Use async/await for network requests with timeout handling
- Support real-time updates without full page refreshes
- Include accessibility features (keyboard navigation, screen readers)

### Dashboard Components

#### Server Status Display
- Show server type icons with clear visual indicators
- Display online/offline status with appropriate colors (green/red/gray)
- Include last seen timestamps and scan information
- Group servers by type with collapsible sections
- Provide quick stats summary (total servers, online count)

#### Connection Management
- Generate one-click connection buttons for each server type
- Create downloadable connection scripts (.rdp, .vnc, .command)
- Include SSH key deployment status indicators
- Support custom connection parameters and ports
- Provide connection testing functionality

#### SSH Key Management Interface
- Generate SSH key creation form with email input
- Display current key status and fingerprint
- Provide key deployment interface with server selection
- Show deployment progress and results
- Include key backup and recovery options

#### Network Configuration
- Custom network range input with validation
- Network scan progress indicators
- Scan history and results display
- Server discovery timeline and statistics
- Network topology visualization if applicable

### Data Integration
- Read server data from `/app/www/data/discovered_servers.json`
- Parse configuration from `/app/www/data/admin_config.json`
- Handle missing or corrupted data files gracefully
- Implement real-time data refresh every 30 seconds
- Cache data appropriately to reduce server load

### Export Functionality
- Generate Remote Desktop Manager (RDM) JSON exports
- Create RDM XML format for legacy compatibility
- Include all necessary connection parameters
- Group exported connections by server type
- Provide download links for generated export files

### Error Handling and User Experience
- Display user-friendly error messages for network issues
- Implement loading states for all async operations
- Provide progress indicators for long-running tasks
- Include retry mechanisms for failed operations
- Show helpful tooltips and guidance text

### Responsive Design Requirements
- Support screen sizes from 320px (mobile) to 1920px+ (desktop)
- Use appropriate touch targets (minimum 44px) for mobile
- Implement swipe gestures for mobile navigation
- Ensure readable text at all zoom levels
- Test with common mobile browsers and devices

### Performance Optimization
- Minimize DOM manipulation for better performance
- Use efficient event handling patterns
- Implement virtual scrolling for large server lists
- Optimize images and assets for fast loading
- Use browser caching appropriately

### Accessibility Standards
- Include ARIA labels and landmarks
- Support keyboard navigation throughout interface
- Provide high contrast mode for visual accessibility
- Include screen reader compatibility
- Follow WCAG 2.1 AA guidelines

### Browser Compatibility
- Support modern browsers (Chrome 88+, Firefox 85+, Safari 14+)
- Include polyfills for essential features only
- Test with common mobile browsers
- Provide fallbacks for unsupported features
- Document browser requirements clearly