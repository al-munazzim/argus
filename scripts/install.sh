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
    pipx install datasette 2>&1 || true
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
echo "══════════════════════════════════════════════════════════════════"
echo "NEXT STEPS"
echo "══════════════════════════════════════════════════════════════════"
echo
echo "1. Set up authentication (choose one):"
echo "   - GitHub:  gh auth login"
echo "   - Forgejo: export ARGUS_BACKEND=tea (needs token with read:notification)"
echo
echo "2. Start the dashboard service:"
echo "   systemctl enable --now argus"
echo
echo "3. Add to your HEARTBEAT.md:"
echo
echo "──────────────────────────────────────────────────────────────────"
cat << 'HEARTBEAT'
### Argus Community Awareness (Daily)
1. **Check status**: `argus status`
2. **Pull notifications** (if auth configured): `argus notif pull`
3. **Review pending**: `argus notif list --pending --limit 5`
4. **Triage**: For each pending notification:
   - If actionable: `argus notif act <id> <action> "<detail>"`
   - If not relevant: `argus notif dismiss <id> "<reason>"`
5. **Audit stale**: `argus notif audit --stale-hours 48`
6. **Log activity**: Record significant actions with `argus activity log`
7. **Check escalations**: `argus escalate list --status open`
HEARTBEAT
echo "──────────────────────────────────────────────────────────────────"
echo
echo "Dashboard URLs (default port 8100):"
echo "  - Dashboard:  http://localhost:8100"
echo "  - Datasette:  http://localhost:8101"
echo
echo "Set ARGUS_PORT to change (e.g., ARGUS_PORT=8200 for 8200/8201)"
echo "══════════════════════════════════════════════════════════════════"
