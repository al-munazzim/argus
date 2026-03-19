-- Argus Database Schema
-- Version: 0.1.0

-- Repositories being tracked
CREATE TABLE IF NOT EXISTS repos (
    id TEXT PRIMARY KEY,          -- owner/repo
    description TEXT,
    is_primary INTEGER DEFAULT 0,
    last_synced_at TEXT
);

-- Issues and PRs
CREATE TABLE IF NOT EXISTS issues (
    id TEXT PRIMARY KEY,          -- owner/repo#number
    repo_id TEXT NOT NULL,
    number INTEGER NOT NULL,
    type TEXT NOT NULL,           -- issue | pr
    title TEXT NOT NULL,
    state TEXT NOT NULL,          -- open | closed | merged
    author TEXT,
    labels TEXT DEFAULT '[]',
    created_at TEXT,
    updated_at TEXT,
    FOREIGN KEY (repo_id) REFERENCES repos(id)
);

-- GitHub notifications
CREATE TABLE IF NOT EXISTS notifications (
    id TEXT PRIMARY KEY,
    issue_id TEXT,
    repo_id TEXT,
    reason TEXT,
    title TEXT,
    url TEXT,
    type TEXT,
    seen_at TEXT,
    acted_at TEXT,
    action_taken TEXT,
    dismissed INTEGER DEFAULT 0,
    filter_reason TEXT,
    is_own_pr INTEGER DEFAULT 0,
    ci_status TEXT,
    FOREIGN KEY (issue_id) REFERENCES issues(id),
    FOREIGN KEY (repo_id) REFERENCES repos(id)
);

-- Filter rules for auto-dismissing notifications
CREATE TABLE IF NOT EXISTS filter_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    field TEXT NOT NULL,          -- reason | repo_id | title | type
    op TEXT NOT NULL,             -- eq | neq | contains | matches
    value TEXT NOT NULL,
    action TEXT DEFAULT 'dismiss', -- dismiss | keep
    priority INTEGER DEFAULT 0,  -- higher = checked first
    enabled INTEGER DEFAULT 1,
    description TEXT
);

-- Activity log
CREATE TABLE IF NOT EXISTS activity_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT DEFAULT (datetime('now')),
    issue_id TEXT,
    action TEXT NOT NULL,
    detail TEXT,
    github_url TEXT,
    FOREIGN KEY (issue_id) REFERENCES issues(id)
);

-- Escalations
CREATE TABLE IF NOT EXISTS escalations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at TEXT DEFAULT (datetime('now')),
    category TEXT NOT NULL,
    priority TEXT DEFAULT 'normal',
    title TEXT NOT NULL,
    detail TEXT,
    status TEXT DEFAULT 'open',
    resolved_at TEXT,
    resolved_by TEXT,
    resolution TEXT
);

-- Poll history
CREATE TABLE IF NOT EXISTS notification_polls (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    polled_at TEXT DEFAULT (datetime('now')),
    new_count INTEGER DEFAULT 0
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_notifications_dismissed ON notifications(dismissed);
CREATE INDEX IF NOT EXISTS idx_notifications_acted ON notifications(acted_at);
CREATE INDEX IF NOT EXISTS idx_activity_timestamp ON activity_log(timestamp);
CREATE INDEX IF NOT EXISTS idx_escalations_status ON escalations(status);
CREATE INDEX IF NOT EXISTS idx_issues_state ON issues(state);
CREATE INDEX IF NOT EXISTS idx_issues_repo ON issues(repo_id);
