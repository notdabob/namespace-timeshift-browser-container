#!/bin/bash

# Container startup script for iDRAC Management
echo "🚀 Starting iDRAC Management Container..."

# Create necessary directories
mkdir -p /app/www/data /app/www/downloads /app/logs /root/.ssh

# Initialize data files
if [ ! -f /app/www/data/discovered_idracs.json ]; then
    echo '{"servers": [], "last_scan": "", "scan_count": 0}' > /app/www/data/discovered_idracs.json
fi

if [ ! -f /app/www/data/admin_config.json ]; then
    echo '{"admin_email": "", "ssh_key_generated": false, "ssh_key_path": "", "last_updated": ""}' > /app/www/data/admin_config.json
fi

# Generate initial dashboard
echo "📊 Generating initial dashboard..."
python3 /app/src/dashboard-generator.py

# Set permissions
chown -R www-data:www-data /app/www
chmod 755 /app/www/downloads

# Add network scanning cron job
echo "*/5 * * * * python3 /app/src/network-scanner.py" | crontab -

echo "✅ Container initialization complete"
echo "🌐 Dashboard will be available on port 80"
echo "🔧 API server will be available on port 8765"

# Start supervisor to manage services
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf