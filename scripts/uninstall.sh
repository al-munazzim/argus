#!/bin/bash
#
# Argus Uninstallation Script
#
set -e

INSTALL_DIR="/opt/argus"
SKILL_LINK="/olymp/shared/skills/argus"

echo "╔════════════════════════════════════════╗"
echo "║        Argus Uninstallation            ║"
echo "╚════════════════════════════════════════╝"
echo

# Stop and disable service
echo "Stopping argus service..."
systemctl stop argus 2>/dev/null || true
systemctl disable argus 2>/dev/null || true

# Remove systemd service
echo "Removing systemd service..."
rm -f /etc/systemd/system/argus.service
systemctl daemon-reload

# Remove CLI symlink
echo "Removing CLI symlink..."
rm -f /usr/local/bin/argus

# Remove skill symlink
echo "Removing skill symlink..."
rm -f "$SKILL_LINK"

# Remove installation directory
echo "Removing installation directory..."
rm -rf "$INSTALL_DIR"

echo
echo "✓ Uninstallation complete!"
echo
echo "Note: User data at ~/.argus/ was preserved."
echo "To remove it: rm -rf ~/.argus"
echo
echo "Datasette was not uninstalled."
echo "To remove it: pip3 uninstall datasette"
