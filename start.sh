#!/bin/bash

# Reticulum startup script for Docker container

set -e

echo "Starting Reticulum Transport Node..."

# Wait for serial device to be available
DEVICE="/dev/ttyUSB0"
MAX_WAIT=30
WAITED=0

while [ ! -e "$DEVICE" ] && [ $WAITED -lt $MAX_WAIT ]; do
    echo "Waiting for $DEVICE to be available... ($WAITED/$MAX_WAIT)"
    sleep 1
    WAITED=$((WAITED + 1))
done

if [ ! -e "$DEVICE" ]; then
    echo "WARNING: $DEVICE not found after $MAX_WAIT seconds"
    echo "LoRa interface will not be available"
elsemk
    echo "Serial device $DEVICE found"
fi

# Check if config exists, if not create default
if [ ! -f "/home/reticulum/.reticulum/config" ]; then
    echo "No config found, creating default configuration..."
    mkdir -p /home/reticulum/.reticulum
    cat > /home/reticulum/.reticulum/config << 'EOF'
# Reticulum Configuration

[reticulum]
enable_transport = yes
share_instance = no
shared_instance_port = 37428
instance_control_port = 37429

[logging]
loglevel = 4

# Local Network Interface for Family/Friends
[[TCP Server Interface]]
type = TCPServerInterface
enabled = yes
listen_ip = 0.0.0.0
listen_port = 4242
i2p_tunneled = no

# Optional: Add authentication
# network_name = family_network_2024
# passphrase = your_secure_passphrase_here

# RNode LoRa Interface
[[RNode LoRa]]
type = RNodeInterface
enabled = yes
port = /dev/ttyUSB0
frequency = 915000000
bandwidth = 125000
txpower = 14
spreadingfactor = 7
codingrate = 5

# Optional: Add authentication to LoRa
# network_name = family_network_2024
# passphrase = your_secure_passphrase_here

# I2P Interface (uncomment to enable)
# [[I2P Interface]]
# type = I2PInterface
# enabled = yes
# connectable = yes

# Local Auto Interface (for local network discovery)
[[Auto Interface]]
type = AutoInterface
enabled = yes
EOF
    echo "Default config created at /home/reticulum/.reticulum/config"
    echo "Please customize as needed!"
fi

# Display configuration info
echo ""
echo "==================================="
echo "Reticulum Node Configuration"
echo "==================================="
echo "Config location: /home/reticulum/.reticulum/config"
echo "Log level: ${RNS_LOGLEVEL:-4}"
echo ""

# Clean up any stale lock files from previous runs
echo "Cleaning up stale lock files..."
rm -f /home/reticulum/.reticulum/.lock
rm -f /home/reticulum/.reticulum/storage/.lock
rm -f /home/reticulum/.reticulum/.shared_instance_lock

# Note: i2pd runs in a separate container (see docker-compose.yml)
# No need to start it here

# Start Reticulum
echo "Starting Reticulum..."
echo ""

# Use rnsd (Reticulum Network Stack Daemon)
# Pass the config directory, not the config file
exec rnsd --config /home/reticulum/.reticulum