# Argus 👁️

CLI tool for GitHub/Forgejo community awareness — tracking notifications, logging activity, managing escalations.

Named after **Argus Panoptes**, the all-seeing giant of Greek mythology.

## Features

- **Notification triage** — Pull, act, or dismiss GitHub notifications
- **Activity logging** — Track community actions
- **Escalation management** — Flag and track issues needing attention
- **Dashboard** — Visual overview via Datasette + static HTML
- **Systemd service** — Run in background

## Quick Start

```bash
# Install
./scripts/install.sh

# Initialize database
argus init

# Set up authentication (choose one)
gh auth login                    # GitHub
export ARGUS_BACKEND=tea         # Forgejo (needs tea token with read:notification)

# Pull notifications
argus notif pull

# Check status
argus status

# Start dashboard
systemctl enable --now argus
```

## Agent Integration

For AI agents using OpenClaw, add this to your `HEARTBEAT.md` for periodic community awareness:

```markdown
### Argus Community Awareness (Daily)
1. **Check status**: `argus status`
2. **Pull notifications**: `argus notif pull`
3. **Review pending**: `argus notif list --pending --limit 5`
4. **Triage**: For each pending notification:
   - If actionable: `argus notif act <id> <action> "<detail>"`
   - If not relevant: `argus notif dismiss <id> "<reason>"`
5. **Audit stale**: `argus notif audit --stale-hours 48`
6. **Log activity**: Record significant actions with `argus activity log`
7. **Check escalations**: `argus escalate list --status open`
```

The install script outputs this block — just copy it to your HEARTBEAT.md.

## Commands

### Core

| Command | Description |
|---------|-------------|
| `argus init` | Create database |
| `argus version` | Show version |
| `argus status` | Summary overview |

### Repositories

| Command | Description |
|---------|-------------|
| `argus repo list` | List watched repositories |
| `argus repo watch <owner/repo>` | Subscribe to a repository |
| `argus repo unwatch <owner/repo>` | Unsubscribe from a repository |

### Notifications

| Command | Description |
|---------|-------------|
| `argus notif pull [--backend gh\|tea]` | Fetch from GitHub/Forgejo |
| `argus notif list [--pending]` | List notifications |
| `argus notif act <id> <action>` | Mark as acted |
| `argus notif dismiss <id> [reason]` | Dismiss |
| `argus notif audit` | Auto-escalate stale |

### Activity

| Command | Description |
|---------|-------------|
| `argus activity log <action> <detail>` | Log action |
| `argus activity list` | Show recent |

### Escalations

| Command | Description |
|---------|-------------|
| `argus escalate create --category --title` | Create |
| `argus escalate list [--status]` | List |
| `argus escalate ack <id>` | Acknowledge |
| `argus escalate resolve <id> --by --resolution` | Resolve |

### Service

| Command | Description |
|---------|-------------|
| `argus serve` | Start Datasette + dashboard |

## Configuration

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `ARGUS_DB` | `~/.argus/argus.db` | Database path |
| `ARGUS_PORT` | `8100` | Dashboard port (datasette runs on port+1) |
| `ARGUS_BACKEND` | `gh` | Backend: `gh` (GitHub) or `tea` (Forgejo) |
| `GH_TOKEN` | — | GitHub API token (for gh backend) |

## Architecture

```
┌─────────────────────────────────────────────────┐
│                    argus CLI                     │
│  notif pull | activity log | escalate | serve   │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│              ~/.argus/argus.db                  │
│   repos | issues | notifications | activity    │
└─────────────────┬───────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
┌───────────────┐   ┌───────────────┐
│   Dashboard   │   │   Datasette   │
│  :PORT (HTML) │   │ :PORT+1 (API) │
└───────────────┘   └───────────────┘
```

Default: Dashboard on 8100, Datasette on 8101. Set `ARGUS_PORT` to change base port.

## Installation

### Prerequisites

- Python 3.9+
- pip
- gh CLI (for GitHub integration)

### Install

```bash
git clone https://forgejo.tail593e12.ts.net/Zeus/argus.git /opt/argus
cd /opt/argus && ./scripts/install.sh
```

### Uninstall

```bash
/opt/argus/scripts/uninstall.sh
```

## Systemd Service

```bash
systemctl enable argus   # Start on boot
systemctl start argus    # Start now
systemctl status argus   # Check status
journalctl -u argus -f   # View logs
```

## License

MIT

## Author

Zeus @ Olymp
