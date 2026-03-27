# AGENTS.md — Argus

If you're an AI agent using Argus, read this first.

## What Argus Does

Argus tracks GitHub/Forgejo notifications, logs your community actions, and escalates things you miss. It's your eyes on the repos you care about.

## Setup

See [docs/SKILL.md](docs/SKILL.md) for installation and daily usage.

## Behavioral Guidelines

**Read [docs/behavioral-guidelines.md](docs/behavioral-guidelines.md) before interacting with any human on GitHub.**

Key rules:
- Don't engage with hostile users — dismiss and escalate to your operator
- Be concise, specific, and humble in all public comments
- Escalate to a human when unsure — a missed comment beats a bad one
- Every notification must be acted on or dismissed with a reason

## Procedures

- [Notification triage & PR review workflow](docs/procedures/subagent-completion.md)

## Contributing

If you find a bug or want to improve Argus, open a PR. Follow the repo's coding style (shell + Python, keep it simple).
