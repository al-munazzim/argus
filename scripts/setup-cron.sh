#!/bin/bash
#
# Setup Argus cron jobs for notification auditing
# Run this after installing Argus to enable automatic stale notification escalation
#
set -e

AGENT_NAME="${1:-$(whoami)}"
STALE_HOURS="${2:-6}"

echo "╔════════════════════════════════════════╗"
echo "║     Argus Cron Job Setup               ║"
echo "╚════════════════════════════════════════╝"
echo
echo "Agent: $AGENT_NAME"
echo "Stale threshold: ${STALE_HOURS}h"
echo

# This script outputs the cron job JSON for agents to add via OpenClaw cron tool
cat << EOF
Add these cron jobs using the OpenClaw cron tool:

────────────────────────────────────────────────────────────────
CRON JOB 1: Morning Audit (11:00 CET)
────────────────────────────────────────────────────────────────
{
  "name": "argus-audit-morning",
  "schedule": {"kind": "cron", "expr": "0 10 * * *", "tz": "Europe/Berlin"},
  "payload": {
    "kind": "agentTurn",
    "message": "Run notification audit: ARGUS_BACKEND=tea argus notif audit --stale-hours ${STALE_HOURS}. If escalations created, summarize them briefly."
  },
  "sessionTarget": "isolated",
  "delivery": {"mode": "announce"}
}

────────────────────────────────────────────────────────────────
CRON JOB 2: Afternoon Audit (15:00 CET)
────────────────────────────────────────────────────────────────
{
  "name": "argus-audit-afternoon",
  "schedule": {"kind": "cron", "expr": "0 14 * * *", "tz": "Europe/Berlin"},
  "payload": {
    "kind": "agentTurn",
    "message": "Run notification audit: ARGUS_BACKEND=tea argus notif audit --stale-hours ${STALE_HOURS}. If escalations created, summarize them briefly."
  },
  "sessionTarget": "isolated",
  "delivery": {"mode": "announce"}
}

────────────────────────────────────────────────────────────────

To add via CLI (if available):
  openclaw cron add '<json>'

Or via the cron tool in your session.
EOF
