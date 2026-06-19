---
name: jules-subagent
version: 1.0.0
description: >
  Use when the user wants to delegate coding tasks to Jules (Google's async coding agent).
  Trigger on: 'ask Jules', 'delegate to Jules', 'send to Jules', 'let Jules do X',
  'Jules should write...', 'use Jules', 'get Jules to...', or any request involving
  Jules as a sub-agent or coding assistant. Handles session creation, monitoring,
  result retrieval, verification, and integration back into the workflow.
metadata:
  author: Nexus (AI Assistant)
  created: 2026-06-19
  language: en
  scope: minis
  tags: [jules, google, coding-agent, subagent, delegation, automation]
---

# Jules Sub-Agent Skill

## Overview

This skill enables delegation of coding tasks to **Jules** — Google's asynchronous coding agent — with full visibility, review, and verification before integration.

## When to Trigger

- User says: *"Ask Jules to..."*, *"Delegate to Jules..."*, *"Let Jules handle..."*
- User says: *"Jules should write..."*, *"Get Jules to..."*, *"Use Jules for..."*
- Any request to use Jules as a sub-agent
- Need to check status of existing Jules session
- Need to review/apply Jules output

## Workflow

### Step 1: Create Session

```bash
jules new "<task description>"
```

Capture the session ID from the output.

### Step 2: Store Session ID

```bash
mkdir -p /var/minis/workspace/jules_work
echo "<SESSION_ID>" > /var/minis/workspace/jules_work/last_session.txt
```

### Step 3: Wait for Completion

Poll until the session is finished:

```bash
jules remote list --session | grep "<SESSION_ID>"
```

Or use the helper script (see Scripts).

### Step 4: Pull Result

```bash
jules remote pull --session <SESSION_ID> > /var/minis/workspace/jules_work/jules_<ID>.patch
```

### Step 5: Verify Before Integration

**ALWAYS review the patch before applying.** Never auto-apply without checking.

#### Verification Checklist:
1. Read the patch content
2. Check what files are modified/created
3. Look for security issues (evals, shell exec, hardcoded secrets)
4. Run any relevant tests if available
5. Apply only when satisfied

```bash
# Preview the patch
cat /var/minis/workspace/jules_work/jules_<ID>.patch

# Apply if approved
git apply /var/minis/workspace/jules_work/jules_<ID>.patch
```

### Step 6: Report Back

Summarize for the user:
- What Jules was asked to do
- What was produced (files, changes)
- Verification status (tested/pending review)
- Any issues found

## Scripts

### jules_delegate.sh

**Path:** `scripts/jules_delegate.sh`

Handles the full delegate-wait-pull pipeline.

**Usage:**
```bash
./scripts/jules_delegate.sh "write a Python function to validate emails"
```

**Actions:**
1. Creates Jules session
2. Saves session ID to `jules_work/last_session.txt`
3. Polls until finished (10s intervals)
4. Pulls patch to `jules_work/jules_<ID>.patch`
5. Reports completion status

### jules_status.sh

**Path:** `scripts/jules_status.sh`

Quick status check for the last (or specified) session.

**Usage:**
```bash
./scripts/jules_status.sh          # check last session
./scripts/jules_status.sh 1234567  # check specific session
```

## Important Rules

### ALWAYS Verify Before Applying
> **Critical:** Never blindly apply Jules output. Review it first.

### Do Not Auto-Apply
- `jules remote pull --session <ID> --apply` is **forbidden** unless user explicitly requests it
- Default is: pull → review → user approves → apply

### Track Delegated Work
- Store session IDs in `/var/minis/workspace/jules_work/`
- Keep patches for reference
- Note what task each session was for

## Error Handling

| Issue | Resolution |
|-------|-----------|
| `jules new` fails | Check `jules login` status and OAuth token |
| Session never finishes | Run `jules remote list --session` to check |
| Pull is empty | Session may still be running or failed |
| Patch fails to apply | Manual review needed; may need to retry with clearer instructions |

## Integration with Minis

| User Request | Action |
|-------------|--------|
| "Ask Jules to..." | Run `jules_delegate.sh` |
| "What did Jules do?" | Read `last_session.txt`, show status |
| "Check Jules' work" | Pull and review the patch |
| "Apply Jules' changes" | Review first, then apply if clean |
| "Jules messed up" | Log issue, possibly retry with clearer instructions |

## Quick Reference

| Command | Purpose |
|---------|---------|
| `jules new "task"` | Create new session |
| `jules remote list --session` | List all sessions |
| `jules remote status --session <ID>` | Check session status |
| `jules remote pull --session <ID>` | Get patch output |
| `jules remote pull --session <ID> --apply` | ⚠️ Auto-apply (skip review) |
| `jules teleport <ID>` | Clone repo + checkout + apply |

## Requirements

- `jules` CLI installed and authenticated
- Valid OAuth token at `~/.jules/cache/oauth_creds.json`
- `/var/minis/workspace/jules_work/` directory exists