# Argus Sub-Agent Procedures

Standard procedures for AI agents performing community management tasks.

## Notification Triage

### Input
- Pending notifications from `argus notif list --pending`

### Process

1. **Classify** each notification:
   - `review-request`: Someone requested your review
   - `mention`: You were mentioned
   - `assign`: Issue/PR was assigned to you
   - `comment`: New comment on subscribed thread
   - `ci-failure`: CI/CD failure notification

2. **Prioritize**:
   - P1 (immediate): Security issues, prod failures
   - P2 (same day): Review requests, direct mentions
   - P3 (when possible): General comments, updates

3. **Act**:
   - For each notification, either:
     - Take action (review, respond, fix)
     - Escalate (create escalation)
     - Dismiss (with reason)

### Output

```bash
# After processing each notification
argus notif act <id> <action> "<brief detail>"

# Or dismiss
argus notif dismiss <id> "<reason>"

# Log activity
argus activity log <action> "<detail>" [--issue <id>]
```

## Pull Request Review

### Input
- PR notification or explicit request

### Process

1. **Read PR**: Check title, description, changes
2. **Assess scope**: Is this a minor fix or major change?
3. **Review code**: Look for issues, suggest improvements
4. **Leave feedback**: Comment on GitHub
5. **Log action**: Record what you did

### Output

```bash
argus notif act <id> reviewed "Approved with comments"
argus activity log pr-review "Reviewed PR #123: Added caching layer"
```

## Escalation Handling

### When to Escalate

- Notification pending > 48 hours
- Security-related issues
- Unclear requirements needing human decision
- Permission/access issues

### Process

```bash
# Create escalation
argus escalate create \
  --category "stale-notification" \
  --title "PR #123 needs maintainer input" \
  --priority high

# After human acknowledges
argus escalate ack <id>

# After resolution
argus escalate resolve <id> \
  --by "k9ert" \
  --resolution "Merged after fixes"
```

## Daily Routine

Suggested daily workflow for automated community management:

```bash
# Morning
argus notif pull
argus status
argus notif list --pending --limit 20

# Process notifications (triage, respond, escalate)
# ... actions ...

# End of day
argus notif audit --stale-hours 48
argus activity list --limit 10
```

## Reporting

For summaries:

```sql
-- Via datasette or direct SQL
SELECT action, COUNT(*) 
FROM activity_log 
WHERE timestamp > date('now', '-7 days')
GROUP BY action;
```

Dashboard at http://localhost:8101 provides visual overview.
