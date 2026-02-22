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

# Set up GitHub token
export GH_TOKEN=your_github_token

# Pull notifications
argus notif pull

# Check status
argus status

# Start dashboard
systemctl start argus
```

## Commands

### Core

| Command | Description |
|---------|-------------|
| `argus init` | Create database |
| `argus version` | Show version |
| `argus status` | Summary overview |

### Notifications

| Command | Description |
|---------|-------------|
| `argus notif pull [--dry-run]` | Fetch from GitHub |
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
| `ARGUS_PORT` | `8100` | Datasette API port |
| `ARGUS_DASHBOARD_PORT` | `8101` | Dashboard port |
| `GH_TOKEN` | — | GitHub API token |

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
│   Datasette   │   │   Dashboard   │
│  :8100 (API)  │   │ :8101 (HTML)  │
└───────────────┘   └───────────────┘
```

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
