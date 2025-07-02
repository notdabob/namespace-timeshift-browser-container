#!/usr/bin/env python3
"""
Network Scanner for iDRAC Discovery
Container-based network scanning without time constraints
"""

import os
import json
import socket
import subprocess
import requests
import threading
from datetime import datetime, timezone
import time

# Configuration
DATA_DIR = '/app/www/data'
SERVERS_FILE = os.path.join(DATA_DIR, 'discovered_idracs.json')
SCAN_TIMEOUT = 3
MAX_WORKERS = 50

def log_message(message):
    """Log message with timestamp"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[SCANNER] [{timestamp}] {message}")

def get_network_range():
    """Get the host's network range for scanning"""
    try:
        # Get all network interfaces
        result = subprocess.run(['ip', 'addr', 'show'], 
                              capture_output=True, text=True)
        if result.returncode == 0:
            # Look for the main ethernet interface (not docker0 or lo)
            for line in result.stdout.split('\n'):
                if 'inet ' in line and '127.0.0.1' not in line and 'docker0' not in line:
                    # Extract IP address
                    ip_info = line.strip().split()[1]
                    ip_addr = ip_info.split('/')[0]
                    
                    # Skip docker bridge networks
                    if not ip_addr.startswith('172.'):
                        network_base = '.'.join(ip_addr.split('.')[:-1])
                        log_message(f"Detected network range: {network_base}.0/24")
                        return f"{network_base}."
    except Exception as e:
        log_message(f"Failed to detect network: {e}")
    
    # Fallback to common ranges
    log_message("Using fallback network range: 192.168.1.0/24")
    return "192.168.1."

def scan_port(ip, port):
    """Scan a single IP and port"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(SCAN_TIMEOUT)
        result = sock.connect_ex((ip, port))
        sock.close()
        return result == 0
    except:
        return False

def get_idrac_info(ip, port):
    """Try to get iDRAC information from web interface"""
    protocols = ['https', 'http'] if port == 443 else ['http']
    
    for protocol in protocols:
        try:
            url = f"{protocol}://{ip}"
            response = requests.get(url, timeout=5, verify=False, 
                                  allow_redirects=False)
            
            # Check for iDRAC indicators in response
            content = response.text.lower()
            headers = str(response.headers).lower()
            
            if any(indicator in content or indicator in headers 
                   for indicator in ['idrac', 'dell', 'integrated dell remote access']):
                
                # Try to extract title
                title = "Dell iDRAC"
                if '<title>' in content:
                    start = content.find('<title>') + 7
                    end = content.find('</title>', start)
                    if end > start:
                        title = content[start:end].strip().title()
                
                return {
                    'url': url,
                    'protocol': protocol.upper(),
                    'title': title,
                    'is_idrac': True
                }
                
        except requests.exceptions.SSLError:
            # SSL error is common with iDRAC6, continue with HTTP
            continue
        except:
            continue
    
    return None

def scan_ip_range(network_base, start, end):
    """Scan a range of IPs"""
    discovered = []
    
    for i in range(start, end + 1):
        ip = f"{network_base}{i}"
        
        # Check common iDRAC ports
        ports_to_check = [443, 80]  # HTTPS first, then HTTP
        
        for port in ports_to_check:
            if scan_port(ip, port):
                log_message(f"Found open port {port} on {ip}")
                
                # Try to identify if it's iDRAC
                idrac_info = get_idrac_info(ip, port)
                if idrac_info:
                    discovered.append(idrac_info)
                    log_message(f"Identified iDRAC: {idrac_info['title']} at {idrac_info['url']}")
                    break  # Found iDRAC, no need to check other ports
    
    return discovered

def load_existing_servers():
    """Load existing server list"""
    if os.path.exists(SERVERS_FILE):
        try:
            with open(SERVERS_FILE, 'r') as f:
                return json.load(f)
        except:
            pass
    
    return {'servers': [], 'last_scan': '', 'scan_count': 0}

def save_servers(data):
    """Save server list to file"""
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(SERVERS_FILE, 'w') as f:
        json.dump(data, f, indent=2)

def update_server_status(servers_data, discovered_servers):
    """Update server status based on scan results"""
    current_time = datetime.now(timezone.utc).isoformat()
    discovered_urls = {server['url'] for server in discovered_servers}
    
    # Update existing servers
    for server in servers_data['servers']:
        if server['url'] in discovered_urls:
            server['status'] = 'online'
            server['last_seen'] = current_time
        else:
            server['status'] = 'offline'
    
    # Add new servers
    existing_urls = {server['url'] for server in servers_data['servers']}
    for discovered in discovered_servers:
        if discovered['url'] not in existing_urls:
            new_server = {
                'url': discovered['url'],
                'protocol': discovered['protocol'],
                'title': discovered['title'],
                'first_discovered': current_time,
                'last_seen': current_time,
                'status': 'online'
            }
            servers_data['servers'].append(new_server)
    
    # Update scan metadata
    servers_data['last_scan'] = current_time
    servers_data['scan_count'] = servers_data.get('scan_count', 0) + 1
    
    return servers_data

def perform_scan():
    """Perform complete network scan"""
    log_message("Starting network scan for iDRAC servers...")
    
    # Get network range
    network_base = get_network_range()
    log_message(f"Scanning network range: {network_base}1-254")
    
    # Divide work among threads
    discovered_servers = []
    threads = []
    
    # Scan in chunks to avoid overwhelming the network
    chunk_size = 10
    for start in range(1, 255, chunk_size):
        end = min(start + chunk_size - 1, 254)
        
        thread = threading.Thread(
            target=lambda s=start, e=end: discovered_servers.extend(
                scan_ip_range(network_base, s, e)
            )
        )
        threads.append(thread)
        thread.start()
        
        # Limit concurrent threads
        if len(threads) >= MAX_WORKERS // chunk_size:
            for t in threads:
                t.join()
            threads = []
    
    # Wait for remaining threads
    for thread in threads:
        thread.join()
    
    log_message(f"Scan complete. Found {len(discovered_servers)} iDRAC servers")
    
    # Update server database
    servers_data = load_existing_servers()
    updated_data = update_server_status(servers_data, discovered_servers)
    save_servers(updated_data)
    
    # Log results
    online_count = len([s for s in updated_data['servers'] if s['status'] == 'online'])
    total_count = len(updated_data['servers'])
    log_message(f"Database updated: {online_count} online, {total_count} total servers")

def main():
    """Main entry point"""
    log_message("iDRAC Network Scanner starting...")
    
    # Ensure data directory exists
    os.makedirs(DATA_DIR, exist_ok=True)
    
    # Perform scan
    try:
        perform_scan()
    except Exception as e:
        log_message(f"Scan failed: {e}")
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())