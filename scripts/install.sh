#!/bin/bash
#
# Argus Installation Script
#
set -e

INSTALL_DIR="/opt/argus"
SKILL_LINK="/olymp/shared/skills/argus"

echo "╔════════════════════════════════════════╗"
echo "║        Argus Installation              ║"
echo "╚════════════════════════════════════════╝"
echo

# Check dependencies
echo "Checking dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is required but not installed."
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "Warning: gh CLI not found. 'argus notif pull' will not work."
fi

# Install datasette if not present
if ! command -v datasette &> /dev/null; then
    echo "Installing datasette..."
    pip3 install datasette --quiet
fi

# Clone or update repo
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull --quiet
else
    echo "Installing to $INSTALL_DIR..."
    # If running from repo directory
    if [ -f "bin/argus" ]; then
        cp -r . "$INSTALL_DIR"
    else
        echo "Error: Run this script from the argus repository directory."
        exit 1
    fi
fi

# Create symlink for CLI
echo "Creating CLI symlink..."
ln -sf "$INSTALL_DIR/bin/argus" /usr/local/bin/argus

# Install systemd service
echo "Installing systemd service..."
cp "$INSTALL_DIR/systemd/argus.service" /etc/systemd/system/
systemctl daemon-reload

# Create skill symlink if /olymp/shared/skills exists
if [ -d "/olymp/shared/skills" ]; then
    echo "Creating skill symlink..."
    ln -sf "$INSTALL_DIR/docs" "$SKILL_LINK"
fi

# Initialize database if not exists
if [ ! -f "$HOME/.argus/argus.db" ]; then
    echo "Initializing database..."
    argus init
fi

echo
echo "✓ Installation complete!"
echo
echo "Next steps:"
echo "  1. Set up GitHub token: export GH_TOKEN=your_token"
echo "  2. Pull notifications: argus notif pull"
echo "  3. Start dashboard: systemctl start argus"
echo
echo "Dashboard will be available at:"
echo "  - Datasette API: http://localhost:8100"
echo "  - Dashboard:     http://localhost:8101"
