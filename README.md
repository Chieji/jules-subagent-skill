# Jules Sub-Agent Skill

A Minis skill for delegating coding tasks to **Jules** — Google's asynchronous coding agent — with full visibility, review, and verification.

## Installation

1. Copy this skill folder to your Minis skills directory:
   ```bash
   cp -r jules-subagent-skill /var/minis/skills/jules-subagent
   ```

2. Ensure the scripts are executable:
   ```bash
   chmod +x /var/minis/skills/jules-subagent/scripts/*.sh
   ```

3. Verify Jules CLI is installed and authenticated:
   ```bash
   jules --version
   jules remote list --session
   ```

## Quick Start

### Delegate a Task

```bash
/var/minis/skills/jules-subagent/scripts/jules_delegate.sh "write a Python function to validate email addresses"
```

This will:
- Create a new Jules session
- Wait for completion
- Save the patch to `/var/minis/workspace/jules_work/`
- Report the result

### Check Status

```bash
/var/minis/skills/jules-subagent/scripts/jules_status.sh
```

## Workflow

```
User Request → Create Session → Wait → Pull Result → Verify → Apply (if approved)
```

## Files

| File | Description |
|------|-------------|
| `SKILL.md` | Main skill definition with full workflow |
| `setup.yaml` | Configuration and metadata |
| `README.md` | This file |
| `scripts/jules_delegate.sh` | Full delegation pipeline |
| `scripts/jules_status.sh` | Status checker |

## License

MIT