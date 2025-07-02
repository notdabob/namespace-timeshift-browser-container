#!/usr/bin/env python3
"""
Dashboard Generator for Container Deployment
Creates web-based iDRAC management interface
"""

import os
import json
from datetime import datetime

# Configuration
WWW_DIR = '/app/www'
DATA_DIR = '/app/www/data'
TEMPLATE_FILE = os.path.join(WWW_DIR, 'index.html')

def generate_dashboard():
    """Generate the main dashboard HTML"""
    
    dashboard_html = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iDRAC Management Dashboard - Container Edition</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
        }
        
        .header h1 {
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 2.5em;
        }
        
        .container-badge {
            background: #27ae60;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            display: inline-block;
            font-weight: bold;
            margin-top: 10px;
        }
        
        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .status-panel {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .management-tools, .ssh-management {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .management-tools h3, .ssh-management h3 {
            margin-bottom: 15px;
            color: #2c3e50;
        }
        
        .ssh-form {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
            margin-bottom: 15px;
        }
        
        .email-input {
            flex: 1;
            min-width: 250px;
            padding: 10px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }
        
        .email-input:focus {
            outline: none;
            border-color: #3498db;
        }
        
        .api-status {
            padding: 8px 12px;
            border-radius: 15px;
            font-size: 0.9em;
            font-weight: bold;
            margin-left: 10px;
        }
        
        .api-status.online {
            background: #d5fdd5;
            color: #27ae60;
        }
        
        .api-status.offline {
            background: #fdd5d5;
            color: #e74c3c;
        }
        
        .ssh-status {
            padding: 8px 12px;
            border-radius: 15px;
            font-size: 0.9em;
            font-weight: bold;
        }
        
        .ssh-status.ready {
            background: #d5fdd5;
            color: #27ae60;
        }
        
        .ssh-status.not-ready {
            background: #fdd5d5;
            color: #e74c3c;
        }
        
        .tool-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .tool-button {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        .primary-button {
            background: #3498db;
            color: white;
        }
        
        .primary-button:hover {
            background: #2980b9;
            transform: scale(1.05);
        }
        
        .success-button {
            background: #27ae60;
            color: white;
        }
        
        .success-button:hover {
            background: #219a52;
            transform: scale(1.05);
        }
        
        .warning-button {
            background: #f39c12;
            color: white;
        }
        
        .warning-button:hover {
            background: #e67e22;
            transform: scale(1.05);
        }
        
        .danger-button {
            background: #e74c3c;
            color: white;
        }
        
        .danger-button:hover {
            background: #c0392b;
            transform: scale(1.05);
        }
        
        .servers-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .server-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
        }
        
        .server-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
        }
        
        .server-card.offline {
            opacity: 0.7;
            border-left: 5px solid #e74c3c;
        }
        
        .server-card.online {
            border-left: 5px solid #27ae60;
        }
        
        .server-status {
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75em;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .status-online {
            background: #d5fdd5;
            color: #27ae60;
        }
        
        .status-offline {
            background: #fdd5d5;
            color: #e74c3c;
        }
        
        .server-title {
            font-size: 1.3em;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
            margin-right: 60px;
        }
        
        .server-url {
            color: #7f8c8d;
            font-size: 0.9em;
            margin-bottom: 15px;
            word-break: break-all;
        }
        
        .server-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .access-button {
            flex: 1;
            padding: 12px 20px;
            background: linear-gradient(45deg, #3498db, #2980b9);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            text-align: center;
            font-weight: bold;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .access-button:hover {
            background: linear-gradient(45deg, #2980b9, #1f5f8b);
            transform: scale(1.02);
        }
        
        .access-button.disabled {
            background: #95a5a6;
            cursor: not-allowed;
            transform: none;
        }
        
        .console-button {
            background: linear-gradient(45deg, #e74c3c, #c0392b) !important;
        }
        
        .console-button:hover {
            background: linear-gradient(45deg, #c0392b, #a93226) !important;
        }
        
        .remove-button {
            padding: 12px 15px;
            background: #e74c3c;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        .remove-button:hover {
            background: #c0392b;
            transform: scale(1.05);
        }
        
        .no-servers {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }
        
        .loading {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }
        
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 8px;
            color: white;
            font-weight: bold;
            z-index: 1000;
            display: none;
        }
        
        .notification.success {
            background: #27ae60;
        }
        
        .notification.error {
            background: #e74c3c;
        }
        
        .notification.info {
            background: #3498db;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖥️ iDRAC Management Dashboard</h1>
        <p>Container-Based Server Management</p>
        <div class="container-badge">
            🐳 Container Edition - No macOS Quarantine Issues!
        </div>
    </div>
    
    <div class="container">
        <div class="status-panel">
            <h3>📊 System Status</h3>
            <div id="system-status">
                <span>API Server:</span> 
                <span class="api-status" id="api-status">🔄 Checking...</span>
                <span style="margin-left: 20px;">Last Scan:</span> 
                <span id="last-scan">Loading...</span>
            </div>
        </div>
        
        <div class="management-tools">
            <h3>🛠️ Server Management</h3>
            <div class="tool-buttons">
                <button class="tool-button danger-button" onclick="cleanupOfflineServers()">
                    🗑️ Remove Offline Servers
                </button>
                <button class="tool-button primary-button" onclick="rescanNetwork()">
                    🔄 Rescan Network
                </button>
                <button class="tool-button primary-button" onclick="refreshDashboard()">
                    ♻️ Refresh Dashboard
                </button>
            </div>
        </div>
        
        <div class="ssh-management">
            <h3>🔐 SSH Key Management</h3>
            <div class="ssh-form">
                <input type="email" class="email-input" id="admin-email" placeholder="Enter admin email address" />
                <div class="ssh-status not-ready" id="ssh-status">
                    🔑 SSH Key Not Generated
                </div>
                <button class="tool-button success-button" onclick="generateSSHKey()">
                    🔑 Generate SSH Key
                </button>
                <button class="tool-button warning-button" onclick="deploySSHKeys()" id="deploy-button" disabled>
                    🚀 Deploy to All Servers
                </button>
            </div>
            <div style="font-size: 0.9em; color: #666; margin-top: 10px;">
                💡 Generate SSH keys for passwordless access to iDRAC servers. Keys stored in container.
            </div>
        </div>
        
        <div id="servers-container">
            <div class="loading">
                <h3>🔄 Loading servers...</h3>
                <p>Scanning network for iDRAC servers...</p>
            </div>
            <div class="servers-grid" id="servers-grid" style="display: none;">
                <!-- Servers will be populated by JavaScript -->
            </div>
        </div>
    </div>
    
    <div class="notification" id="notification"></div>
    
    <script>
        // Global state
        let serverData = { servers: [], last_scan: '', scan_count: 0 };
        let adminConfig = { admin_email: '', ssh_key_generated: false, ssh_key_path: '', last_updated: '' };
        let apiOnline = false;
        
        // Utility functions
        function showNotification(message, type = 'info') {
            const notification = document.getElementById('notification');
            notification.textContent = message;
            notification.className = `notification ${type}`;
            notification.style.display = 'block';
            
            setTimeout(() => {
                notification.style.display = 'none';
            }, 5000);
        }
        
        function formatDate(dateString) {
            if (!dateString) return 'Never';
            const date = new Date(dateString);
            return date.toLocaleString();
        }
        
        function timeSince(dateString) {
            if (!dateString) return 'Unknown';
            const now = new Date();
            const date = new Date(dateString);
            const seconds = Math.floor((now - date) / 1000);
            
            if (seconds < 60) return 'Just now';
            if (seconds < 3600) return Math.floor(seconds / 60) + ' minutes ago';
            if (seconds < 86400) return Math.floor(seconds / 3600) + ' hours ago';
            return Math.floor(seconds / 86400) + ' days ago';
        }
        
        // API communication
        async function callAPI(command, params = {}) {
            try {
                const response = await fetch('/api/', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ command, params })
                });
                
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                
                return await response.json();
            } catch (error) {
                console.error('API call failed:', error);
                throw error;
            }
        }
        
        // Status checking
        async function checkAPIStatus() {
            try {
                const response = await fetch('/api/status');
                const data = await response.json();
                
                if (data.status === 'running') {
                    apiOnline = true;
                    document.getElementById('api-status').textContent = '✅ Online';
                    document.getElementById('api-status').className = 'api-status online';
                } else {
                    throw new Error('API not running');
                }
            } catch (error) {
                apiOnline = false;
                document.getElementById('api-status').textContent = '❌ Offline';
                document.getElementById('api-status').className = 'api-status offline';
            }
        }
        
        // Data loading
        async function loadServerData() {
            try {
                const response = await fetch('/data/discovered_idracs.json');
                serverData = await response.json();
                
                document.getElementById('last-scan').textContent = formatDate(serverData.last_scan);
                renderServers();
            } catch (error) {
                console.error('Failed to load server data:', error);
                showNotification('Failed to load server data', 'error');
            }
        }
        
        async function loadAdminConfig() {
            try {
                const response = await fetch('/data/admin_config.json');
                adminConfig = await response.json();
                
                document.getElementById('admin-email').value = adminConfig.admin_email || '';
                updateSSHStatus();
            } catch (error) {
                console.log('Admin config not found, using defaults');
                updateSSHStatus();
            }
        }
        
        // Server management
        function renderServers() {
            const container = document.getElementById('servers-grid');
            const loadingDiv = document.querySelector('.loading');
            
            if (serverData.servers.length === 0) {
                loadingDiv.innerHTML = `
                    <h3>No iDRAC servers found</h3>
                    <p>Click "Rescan Network" to search for servers</p>
                `;
                container.style.display = 'none';
                return;
            }
            
            loadingDiv.style.display = 'none';
            container.style.display = 'grid';
            
            container.innerHTML = serverData.servers.map(server => {
                const statusClass = `status-${server.status}`;
                const cardClass = server.status;
                const isOffline = server.status === 'offline';
                
                return `
                    <div class="server-card ${cardClass}">
                        <div class="server-status ${statusClass}">${server.status}</div>
                        <div class="server-title">${server.title}</div>
                        <div class="server-url">${server.url}</div>
                        <div style="font-size: 0.8em; color: #95a5a6; margin-bottom: 15px;">
                            <div>First seen: ${formatDate(server.first_discovered)}</div>
                            <div>Last seen: ${timeSince(server.last_seen)}</div>
                        </div>
                        <div class="server-actions">
                            <button class="access-button ${isOffline ? 'disabled' : ''}" 
                               onclick="${isOffline ? 'return false;' : `openIDRAC('${server.url}')`}" 
                               ${isOffline ? 'disabled' : ''}>
                               ${isOffline ? '⚠️ Offline' : '🔗 Access iDRAC'}
                            </button>
                            <button class="access-button console-button ${isOffline ? 'disabled' : ''}" 
                               onclick="${isOffline ? 'return false;' : `launchVirtualConsole('${server.url}')`}" 
                               ${isOffline ? 'disabled' : ''}>
                               ${isOffline ? '⚠️ Offline' : '🖥️ Virtual Console'}
                            </button>
                            <button class="remove-button" onclick="removeServer('${server.url}')" title="Remove from dashboard">
                                ❌
                            </button>
                        </div>
                    </div>
                `;
            }).join('');
        }
        
        // Server actions
        function openIDRAC(url) {
            window.open(url, '_blank');
        }
        
        async function launchVirtualConsole(url) {
            if (!apiOnline) {
                showNotification('API server offline. Opening iDRAC console manually.', 'warning');
                window.open(url + '/console', '_blank');
                return;
            }
            
            try {
                const ip = url.replace(/https?:\\/\\//, '').split('/')[0];
                const result = await callAPI('launch_virtual_console', { ip });
                
                if (result.status === 'success') {
                    showNotification(result.message, 'success');
                    // Also open the console URL
                    window.open(result.console_url, '_blank');
                } else {
                    throw new Error(result.error || 'Failed to launch console');
                }
            } catch (error) {
                showNotification(`Console launch failed: ${error.message}`, 'error');
                // Fallback to direct URL
                window.open(url + '/console', '_blank');
            }
        }
        
        async function removeServer(url) {
            if (!confirm('Remove this server from the dashboard?')) return;
            
            if (!apiOnline) {
                showNotification('API server offline. Cannot remove server.', 'error');
                return;
            }
            
            try {
                const result = await callAPI('remove_server', { url });
                
                if (result.status === 'success') {
                    showNotification(result.message, 'success');
                    await loadServerData();
                } else {
                    throw new Error(result.error || 'Failed to remove server');
                }
            } catch (error) {
                showNotification(`Remove failed: ${error.message}`, 'error');
            }
        }
        
        async function rescanNetwork() {
            if (!apiOnline) {
                showNotification('API server offline. Cannot rescan network.', 'error');
                return;
            }
            
            try {
                const result = await callAPI('rescan_network');
                
                if (result.status === 'success') {
                    showNotification('Network rescan started. Refreshing in 30 seconds...', 'info');
                    
                    setTimeout(async () => {
                        await loadServerData();
                        showNotification('Dashboard refreshed with latest scan results', 'success');
                    }, 30000);
                } else {
                    throw new Error(result.error || 'Failed to start rescan');
                }
            } catch (error) {
                showNotification(`Rescan failed: ${error.message}`, 'error');
            }
        }
        
        async function cleanupOfflineServers() {
            const offlineCount = serverData.servers.filter(s => s.status === 'offline').length;
            
            if (offlineCount === 0) {
                showNotification('No offline servers to remove.', 'info');
                return;
            }
            
            if (!confirm(`Remove ${offlineCount} offline server(s) from the dashboard?`)) return;
            
            // Remove offline servers locally (since this is a simple operation)
            serverData.servers = serverData.servers.filter(s => s.status !== 'offline');
            renderServers();
            showNotification(`Removed ${offlineCount} offline servers`, 'success');
        }
        
        function refreshDashboard() {
            location.reload();
        }
        
        // SSH Key Management
        function updateSSHStatus() {
            const statusElement = document.getElementById('ssh-status');
            const deployButton = document.getElementById('deploy-button');
            
            if (adminConfig.ssh_key_generated) {
                statusElement.textContent = '✅ SSH Key Ready';
                statusElement.className = 'ssh-status ready';
                deployButton.disabled = false;
            } else {
                statusElement.textContent = '🔑 SSH Key Not Generated';
                statusElement.className = 'ssh-status not-ready';
                deployButton.disabled = true;
            }
        }
        
        async function generateSSHKey() {
            const email = document.getElementById('admin-email').value;
            
            if (!email || !email.includes('@')) {
                showNotification('Please enter a valid email address first.', 'error');
                return;
            }
            
            if (!apiOnline) {
                showNotification('API server offline. Cannot generate SSH key.', 'error');
                return;
            }
            
            try {
                const result = await callAPI('generate_ssh_key', { email });
                
                if (result.status === 'success') {
                    adminConfig.admin_email = email;
                    adminConfig.ssh_key_generated = true;
                    adminConfig.ssh_key_path = result.key_path;
                    adminConfig.last_updated = new Date().toISOString();
                    
                    updateSSHStatus();
                    showNotification(result.message, 'success');
                } else {
                    throw new Error(result.error || 'SSH key generation failed');
                }
            } catch (error) {
                showNotification(`SSH key generation failed: ${error.message}`, 'error');
            }
        }
        
        async function deploySSHKeys() {
            if (!apiOnline) {
                showNotification('API server offline. Cannot deploy SSH keys.', 'error');
                return;
            }
            
            const onlineServers = serverData.servers.filter(s => s.status === 'online');
            
            if (onlineServers.length === 0) {
                showNotification('No online servers found to deploy SSH keys to.', 'warning');
                return;
            }
            
            try {
                const result = await callAPI('deploy_ssh_keys');
                
                if (result.status === 'success') {
                    const successCount = result.results.filter(r => r.success).length;
                    showNotification(`SSH deployment complete: ${successCount}/${result.results.length} servers`, 'success');
                } else {
                    throw new Error(result.error || 'SSH deployment failed');
                }
            } catch (error) {
                showNotification(`SSH deployment failed: ${error.message}`, 'error');
            }
        }
        
        // Initialize dashboard
        async function initializeDashboard() {
            await checkAPIStatus();
            await loadServerData();
            await loadAdminConfig();
            
            // Set up periodic status checks
            setInterval(checkAPIStatus, 30000);
            setInterval(loadServerData, 60000);
        }
        
        // Start the dashboard when page loads
        document.addEventListener('DOMContentLoaded', initializeDashboard);
    </script>
</body>
</html>'''
    
    # Ensure directory exists
    os.makedirs(WWW_DIR, exist_ok=True)
    
    # Write dashboard file
    with open(TEMPLATE_FILE, 'w') as f:
        f.write(dashboard_html)
    
    print(f"Dashboard generated: {TEMPLATE_FILE}")

if __name__ == '__main__':
    generate_dashboard()