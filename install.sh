#!/bin/bash

# Build Watcher Installer Script
# This script installs and configures the build-watcher service

set -e

echo "=========================================="
echo "Build Watcher Installation Script"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root"
    echo "Please run: sudo bash install.sh"
    exit 1
fi

# Detect the installation method
if [ -f "./build-watcher.sh" ]; then
    # Installing from local files
    echo "Installing from local directory..."
    SCRIPT_SOURCE="./build-watcher.sh"
    SERVICE_SOURCE="./build-watcher.service"
else
    # Installing from GitHub
    echo "Installing from GitHub repository..."
    REPO_URL="https://raw.githubusercontent.com/imlolman/build-watcher/refs/heads/main"
    
    # Download files
    echo "Downloading build-watcher.sh..."
    curl -fsSL "$REPO_URL/build-watcher.sh" -o /tmp/build-watcher.sh
    
    echo "Downloading build-watcher.service..."
    curl -fsSL "$REPO_URL/build-watcher.service" -o /tmp/build-watcher.service
    
    SCRIPT_SOURCE="/tmp/build-watcher.sh"
    SERVICE_SOURCE="/tmp/build-watcher.service"
fi

# Install the script
echo "Installing build-watcher.sh to /usr/local/bin/..."
cp "$SCRIPT_SOURCE" /usr/local/bin/build-watcher.sh
chmod +x /usr/local/bin/build-watcher.sh

# Install the service file
echo "Installing systemd service..."
cp "$SERVICE_SOURCE" /etc/systemd/system/build-watcher.service

# Reload systemd
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable the service
echo "Enabling build-watcher service..."
systemctl enable build-watcher.service

# Start the service
echo "Starting build-watcher service..."
systemctl start build-watcher.service

# Clean up temporary files if downloaded from GitHub
if [ "$SCRIPT_SOURCE" = "/tmp/build-watcher.sh" ]; then
    rm -f /tmp/build-watcher.sh /tmp/build-watcher.service
fi

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "The build-watcher service is now running."
echo ""
echo "Useful commands:"
echo "  - Check status:  sudo systemctl status build-watcher"
echo "  - View logs:     sudo journalctl -u build-watcher -f"
echo "  - Stop service:  sudo systemctl stop build-watcher"
echo "  - Start service: sudo systemctl start build-watcher"
echo "  - Restart:       sudo systemctl restart build-watcher"
echo "  - Disable:       sudo systemctl disable build-watcher"
echo ""
