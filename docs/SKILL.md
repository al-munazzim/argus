---
name: argus
description: "GitHub/Forgejo community awareness tool. TRIGGERS: notifications, community triage, PR reviews, issue tracking, escalations. Use when managing GitHub notifications, logging community actions, or tracking escalations."
---

# Argus Skill

CLI tool for GitHub/Forgejo community awareness — tracking notifications, logging activity, managing escalations.

## Quick Start

```bash
# Initialize database
argus init

# Pull notifications from GitHub
argus notif pull

# View status
argus status

# Start dashboard
argus serve
```

## Commands

### Status & Info

```bash
argus version           # Show version
argus status            # Summary: pending, activity, escalations
```

### Notifications

```bash
argus notif pull [--dry-run]       # Fetch from GitHub API
argus notif list [--pending]       # List notifications
argus notif act <id> <action>      # Mark as acted
argus notif dismiss <id> [reason]  # Dismiss
argus notif audit [--stale-hours]  # Auto-escalate stale
```

### Activity Logging

```bash
argus activity log <action> <detail> [--issue ID]
argus activity list [--limit N]
```

### Escalations

```bash
argus escalate create --category CAT --title "..."
argus escalate list [--status open]
argus escalate ack <id>
argus escalate resolve <id> --by WHO --resolution "..."
```

### Service

```bash
argus serve [--port 8100] [--dashboard-port 8101]
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ARGUS_DB` | `~/.argus/argus.db` | Database path |
| `ARGUS_PORT` | `8100` | Datasette port |
| `ARGUS_DASHBOARD_PORT` | `8101` | Dashboard port |
| `GH_TOKEN` | — | GitHub API token |

## Workflow

1. **Pull notifications:** `argus notif pull`
2. **Review pending:** `argus notif list --pending`
3. **Act or dismiss:** `argus notif act <id> reviewed` or `argus notif dismiss <id> duplicate`
4. **Log activity:** `argus activity log commented "Answered question"`
5. **Check dashboard:** Open http://localhost:8101

## Sub-Agent Usage

For automated community management:

```
Read notifications with argus notif list --pending.
For each notification:
- If PR: review changes, comment if needed
- If issue: assess priority, respond or escalate
- Log action with argus activity log
After processing: argus notif audit
```

See `procedures/subagent-completion.md` for detailed patterns.
