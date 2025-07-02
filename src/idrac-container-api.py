#!/usr/bin/env python3
"""
iDRAC Container API Server
Provides container-based iDRAC management without time-shifting requirements
"""

import os
import json
import subprocess
import threading
import time
from datetime import datetime
from flask import Flask, request, jsonify, send_from_directory
import paramiko

app = Flask(__name__)

# Configuration
DATA_DIR = '/app/www/data'
DOWNLOADS_DIR = '/app/www/downloads'
LOGS_DIR = '/app/logs'

def log_message(message):
    """Log message with timestamp"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] {message}")

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'iDRAC API'})

@app.route('/status')
def api_status():
    """API status endpoint"""
    return jsonify({
        'status': 'running',
        'server': 'iDRAC Container API',
        'version': '3.0.0',
        'capabilities': [
            'ssh_key_generation',
            'ssh_key_deployment', 
            'idrac_console_access',
            'network_scanning',
            'server_management'
        ]
    })

@app.route('/', methods=['POST'])
@app.route('/execute', methods=['POST'])
def execute_command():
    """Execute iDRAC management commands"""
    try:
        data = request.get_json()
        command = data.get('command')
        params = data.get('params', {})
        
        log_message(f"Executing command: {command} with params: {params}")
        
        if command == 'generate_ssh_key':
            return generate_ssh_key(params.get('email'))
        elif command == 'deploy_ssh_keys':
            return deploy_ssh_keys()
        elif command == 'launch_virtual_console':
            return launch_virtual_console(params.get('ip'))
        elif command == 'rescan_network':
            return rescan_network()
        elif command == 'remove_server':
            return remove_server(params.get('url'))
        else:
            return jsonify({'error': f'Unknown command: {command}'}), 400
            
    except Exception as e:
        log_message(f"Error executing command: {str(e)}")
        return jsonify({'error': str(e)}), 500

def generate_ssh_key(email):
    """Generate SSH key for iDRAC access"""
    if not email:
        return jsonify({'error': 'Email address required'}), 400
    
    try:
        # Generate SSH key
        key_path = '/root/.ssh/idrac_rsa'
        cmd = [
            'ssh-keygen', '-t', 'rsa', '-b', '4096',
            '-C', email, '-f', key_path, '-N', ''
        ]
        
        # Remove existing key if present
        for ext in ['', '.pub']:
            if os.path.exists(f"{key_path}{ext}"):
                os.remove(f"{key_path}{ext}")
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            # Read public key
            with open(f"{key_path}.pub", 'r') as f:
                public_key = f.read().strip()
            
            # Update admin config
            config_file = os.path.join(DATA_DIR, 'admin_config.json')
            config = {
                'admin_email': email,
                'ssh_key_generated': True,
                'ssh_key_path': key_path,
                'public_key': public_key,
                'last_updated': datetime.now().isoformat()
            }
            
            with open(config_file, 'w') as f:
                json.dump(config, f, indent=2)
            
            log_message(f"SSH key generated for {email}")
            
            return jsonify({
                'status': 'success',
                'message': f'SSH key generated for {email}',
                'key_path': key_path,
                'public_key': public_key
            })
        else:
            return jsonify({'error': f'SSH key generation failed: {result.stderr}'}), 500
            
    except Exception as e:
        return jsonify({'error': f'Failed to generate SSH key: {str(e)}'}), 500

def deploy_ssh_keys():
    """Deploy SSH keys to all discovered iDRAC servers"""
    try:
        # Read server list
        servers_file = os.path.join(DATA_DIR, 'discovered_idracs.json')
        if not os.path.exists(servers_file):
            return jsonify({'error': 'No discovered servers found'}), 400
        
        with open(servers_file, 'r') as f:
            data = json.load(f)
        
        online_servers = [s for s in data.get('servers', []) if s.get('status') == 'online']
        
        if not online_servers:
            return jsonify({'error': 'No online servers found'}), 400
        
        # Check if SSH key exists
        key_path = '/root/.ssh/idrac_rsa'
        pub_key_path = f"{key_path}.pub"
        
        if not os.path.exists(pub_key_path):
            return jsonify({'error': 'SSH public key not found. Generate key first.'}), 400
        
        results = []
        
        for server in online_servers:
            ip = server['url'].replace('https://', '').replace('http://', '').split('/')[0]
            
            try:
                # Use ssh-copy-id to deploy key
                cmd = ['ssh-copy-id', '-i', pub_key_path, '-o', 'StrictHostKeyChecking=no', 
                       '-o', 'ConnectTimeout=10', f'root@{ip}']
                
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
                
                success = result.returncode == 0
                results.append({
                    'ip': ip,
                    'success': success,
                    'message': result.stdout if success else result.stderr
                })
                
                # Update SSH config
                if success:
                    update_ssh_config(ip)
                
            except subprocess.TimeoutExpired:
                results.append({
                    'ip': ip,
                    'success': False,
                    'message': 'Connection timeout'
                })
            except Exception as e:
                results.append({
                    'ip': ip,
                    'success': False,
                    'message': str(e)
                })
        
        successful = len([r for r in results if r['success']])
        
        log_message(f"SSH deployment complete: {successful}/{len(results)} servers")
        
        return jsonify({
            'status': 'success',
            'message': f'SSH deployment complete: {successful}/{len(results)} servers',
            'results': results
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to deploy SSH keys: {str(e)}'}), 500

def update_ssh_config(ip):
    """Update SSH config with server entry"""
    ssh_config_path = '/root/.ssh/config'
    alias = f"idrac-{ip.replace('.', '-')}"
    
    # Check if entry already exists
    if os.path.exists(ssh_config_path):
        with open(ssh_config_path, 'r') as f:
            if f"Host {alias}" in f.read():
                return  # Already exists
    
    # Add new entry
    config_entry = f"""
Host {alias}
    HostName {ip}
    User root
    Port 22
    IdentityFile /root/.ssh/idrac_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
"""
    
    with open(ssh_config_path, 'a') as f:
        f.write(config_entry)

def launch_virtual_console(ip):
    """Launch Virtual Console for iDRAC server"""
    if not ip:
        return jsonify({'error': 'IP address required'}), 400
    
    try:
        # For container deployment, we provide connection instructions
        # instead of trying to launch applications
        
        # Check if server is accessible
        cmd = ['ping', '-c', '1', '-W', '3', ip]
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            console_url = f"https://{ip}/console"
            
            # Generate download script for users
            script_content = f"""#!/bin/bash
# Virtual Console Launcher for {ip}
# Run this on your local machine

echo "Connecting to iDRAC Virtual Console at {ip}..."
echo "Opening browser to: https://{ip}/console"

# Try to open in default browser
if command -v open >/dev/null; then
    open "https://{ip}/console"  # macOS
elif command -v xdg-open >/dev/null; then
    xdg-open "https://{ip}/console"  # Linux
elif command -v start >/dev/null; then
    start "https://{ip}/console"  # Windows
else
    echo "Please open this URL manually: https://{ip}/console"
fi

echo ""
echo "Default iDRAC credentials:"
echo "Username: root"
echo "Password: calvin"
"""
            
            # Save script to downloads
            script_file = os.path.join(DOWNLOADS_DIR, f"connect-{ip}.sh")
            with open(script_file, 'w') as f:
                f.write(script_content)
            os.chmod(script_file, 0o755)
            
            log_message(f"Virtual Console access prepared for {ip}")
            
            return jsonify({
                'status': 'success',
                'message': f'Virtual Console access prepared for {ip}',
                'console_url': console_url,
                'download_script': f"connect-{ip}.sh",
                'instructions': 'Download the connection script or access the URL directly'
            })
        else:
            return jsonify({'error': f'Server {ip} is not accessible'}), 400
            
    except Exception as e:
        return jsonify({'error': f'Failed to prepare Virtual Console: {str(e)}'}), 500

def rescan_network():
    """Trigger network rescan"""
    try:
        # Trigger the network scanner
        subprocess.Popen(['python3', '/app/src/network-scanner.py'])
        
        return jsonify({
            'status': 'success',
            'message': 'Network rescan started',
            'action': 'refresh_in_30_seconds'
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to start network rescan: {str(e)}'}), 500

def remove_server(url):
    """Remove server from discovered list"""
    try:
        servers_file = os.path.join(DATA_DIR, 'discovered_idracs.json')
        
        if not os.path.exists(servers_file):
            return jsonify({'error': 'No servers file found'}), 400
        
        with open(servers_file, 'r') as f:
            data = json.load(f)
        
        # Remove server from list
        data['servers'] = [s for s in data['servers'] if s['url'] != url]
        
        with open(servers_file, 'w') as f:
            json.dump(data, f, indent=2)
        
        log_message(f"Removed server: {url}")
        
        return jsonify({
            'status': 'success',
            'message': f'Server removed: {url}'
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to remove server: {str(e)}'}), 500

if __name__ == '__main__':
    log_message("Starting iDRAC Container API Server...")
    
    # Ensure directories exist
    os.makedirs(DATA_DIR, exist_ok=True)
    os.makedirs(DOWNLOADS_DIR, exist_ok=True)
    os.makedirs(LOGS_DIR, exist_ok=True)
    
    # Run Flask app
    app.run(host='0.0.0.0', port=8765, debug=False)