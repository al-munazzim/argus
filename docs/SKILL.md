---
name: argus
description: "GitHub/Forgejo community awareness tool. TRIGGERS: notifications, community triage, PR reviews, issue tracking, escalations, watch repos. Use when managing GitHub/Forgejo notifications, logging community actions, tracking escalations, or setting up community monitoring."
---

# Argus Skill

CLI tool for GitHub/Forgejo community awareness — tracking notifications, logging activity, managing escalations.

## Installation (For Agents)

If `argus` is not installed, run these steps:

### Step 1: Install Argus

```bash
git clone https://forgejo.tail593e12.ts.net/Zeus/argus.git /opt/argus
cd /opt/argus && ./scripts/install.sh
ln -sf ~/.local/bin/datasette /usr/local/bin/datasette 2>/dev/null || true
```

### Step 2: Create Forgejo Token

You need your Forgejo password. Check your git config:
```bash
grep -o 'https://[^:]*:[^@]*@' ~/.openclaw/workspace/.git/config | head -1
```

Then create a token with notification scope:
```bash
# Replace YOURNAME and YOURPASSWORD
curl -s -X POST "https://forgejo.tail593e12.ts.net/api/v1/users/YOURNAME/tokens" \
  -u "YOURNAME:YOURPASSWORD" \
  -H "Content-Type: application/json" \
  -d '{"name":"argus","scopes":["read:notification","read:repository","write:repository"]}' | jq -r '.sha1'
```

### Step 3: Configure Tea

```bash
mkdir -p ~/.config/tea
cat > ~/.config/tea/config.yml << EOF
logins:
  - name: olymp
    url: https://forgejo.tail593e12.ts.net
    token: TOKEN_FROM_STEP_2
    default: true
    user: YOURNAME
EOF
```

### Step 4: Watch Repos & Test

```bash
# Watch repos you care about
argus repo watch owner/repo

# Test notification pull
argus notif pull --backend tea

# Check status
argus status
```

### Step 5: Add to HEARTBEAT.md

Add this block to your HEARTBEAT.md:

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

### Step 6: Start Service (Optional)

```bash
systemctl enable --now argus
```

Dashboard: http://localhost:8100

---

## Daily Usage

Once installed, use these commands:

### Status

```bash
argus version           # Show version
argus status            # Summary: pending, activity, escalations
```

### Repositories

```bash
argus repo list                    # List watched repos
argus repo watch <owner/repo>      # Subscribe to repo
argus repo unwatch <owner/repo>    # Unsubscribe from repo
```

### Notifications

```bash
argus notif pull [--backend gh|tea]  # Fetch notifications
argus notif list [--pending]         # List notifications
argus notif act <id> <action>        # Mark as acted
argus notif dismiss <id> [reason]    # Dismiss
argus notif audit [--stale-hours]    # Auto-escalate stale
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

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ARGUS_DB` | `~/.argus/argus.db` | Database path |
| `ARGUS_PORT` | `8100` | Dashboard port (datasette on port+1) |
| `ARGUS_BACKEND` | `gh` | Backend: `gh` (GitHub) or `tea` (Forgejo) |

## Triage Workflow

1. **Pull**: `argus notif pull`
2. **Review**: `argus notif list --pending`
3. **For each notification**:
   - Check the issue/PR (URL provided)
   - If actionable: `argus notif act <id> reviewed "Added comment"`
   - If not relevant: `argus notif dismiss <id> "Not my area"`
4. **Audit**: `argus notif audit` (escalates stale items)
5. **Log**: `argus activity log triage "Processed 5 notifications"`

---

## Cron Jobs (Automated Auditing)

Set up cron jobs to automatically audit stale notifications twice daily.

### Step 1: Add Cron Jobs

Use the OpenClaw `cron` tool to add these jobs:

**Morning Audit (11:00 CET):**
```json
{
  "name": "argus-audit-morning",
  "schedule": {"kind": "cron", "expr": "0 10 * * *", "tz": "Europe/Berlin"},
  "payload": {
    "kind": "agentTurn",
    "message": "Run notification audit: ARGUS_BACKEND=tea argus notif audit --stale-hours 6. If escalations created, summarize them briefly."
  },
  "sessionTarget": "isolated",
  "delivery": {"mode": "announce"}
}
```

**Afternoon Audit (15:00 CET):**
```json
{
  "name": "argus-audit-afternoon", 
  "schedule": {"kind": "cron", "expr": "0 14 * * *", "tz": "Europe/Berlin"},
  "payload": {
    "kind": "agentTurn",
    "message": "Run notification audit: ARGUS_BACKEND=tea argus notif audit --stale-hours 6. If escalations created, summarize them briefly."
  },
  "sessionTarget": "isolated",
  "delivery": {"mode": "announce"}
}
```

### Step 2: Verify Cron Jobs

Check that the jobs are registered:
```bash
# Via cron tool
cron list
```

Expected output should show `argus-audit-morning` and `argus-audit-afternoon`.

### What the Audit Does

- Checks all pending notifications older than 6 hours
- Creates escalations for stale items
- Reports summary back to your channel

Adjust `--stale-hours` based on your responsiveness requirements.
