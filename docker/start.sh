#!/bin/bash

# Container startup script for Multi-Server Management
echo "🚀 Starting Multi-Server Management Container..."

# Create necessary directories
mkdir -p /app/www/data /app/www/downloads /app/logs /root/.ssh

# Initialize data files using Python script
echo "📁 Initializing data files..."
python3 /app/src/init-data.py

# Legacy support
if [ ! -f /app/www/data/admin_config.json ]; then
    echo '{"admin_email": "", "ssh_key_generated": false, "ssh_key_path": "", "last_updated": ""}' > /app/www/data/admin_config.json
fi

# Generate initial dashboard
echo "📊 Generating initial dashboard..."
python3 /app/src/dashboard-generator.py

# Set permissions
chown -R www-data:www-data /app/www
chmod 755 /app/www/downloads

# Remove old cron job (scanner now runs continuously)
# echo "*/5 * * * * python3 /app/src/network-scanner.py" | crontab -

echo "✅ Container initialization complete"
echo "🌐 Dashboard will be available on port 80"
echo "🔧 API server will be available on port 8765"

# Start supervisor to manage services
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf