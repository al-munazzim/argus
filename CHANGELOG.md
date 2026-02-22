# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-02-22

### Added
- Repository watching commands: `argus repo list|watch|unwatch`
- Subscribe/unsubscribe to repos for notifications
- Works with both gh and tea backends

## [0.2.0] - 2026-02-22

### Added
- Backend flag: `--backend gh|tea` for GitHub or Forgejo support
- `ARGUS_BACKEND` environment variable (default: `gh`)
- Forgejo notifications via `tea` CLI

### Changed
- Simplified port config: single `ARGUS_PORT` (dashboard), datasette on port+1
- Removed `ARGUS_DASHBOARD_PORT` env var

## [0.1.0] - 2026-02-22

### Added
- Initial release
- CLI with notification, activity, and escalation commands
- SQLite database for persistent state
- Datasette integration for API access
- Static HTML dashboard
- Systemd service for background operation
- Install/uninstall scripts
