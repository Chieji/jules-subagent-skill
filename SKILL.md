# Jules Sub-Agent Skill

Delegate coding tasks to Google's Jules async coding agent with full workflow automation.

## Description

This skill enables Minis to delegate software development tasks to Google Jules, manage the async workflow, and ensure code quality through review-before-apply verification. Jules handles the actual coding while Minis orchestrates the delegation, tracks progress, and safeguards against automatic deployment of unverified code.

## Trigger Conditions

The skill activates when user input contains ANY of these patterns:

| Priority | Trigger Phrase | Example |
|----------|----------------|---------|
| **P1** | "ask Jules to" | "Ask Jules to write a React component" |
| **P1** | "delegate to Jules" | "Delegate the API integration to Jules" |
| **P1** | "let Jules handle" | "Let Jules handle the error handling" |
| **P2** | "Jules should write" | "Jules should write the database schema" |
| **P2** | "get Jules to" | "Get Jules to fix the bug" |
| **P2** | "use Jules for" | "Use Jules for the frontend work" |
| **P3** | "what did Jules do" | "What did Jules do on the login task?" |
| **P3** | "check Jules" | "Check Jules' progress" |
| **P3** | "apply Jules'" | "Apply Jules' changes to main" |

## Workflow

### Full Delegation Cycle

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ 1. CREATE       │───▶│ 2. WAIT         │───▶│ 3. PULL         │
│ jules new --repo│    │ Poll every 10s  │    │ jules remote    │
│ "task"          │    │ until finished  │    │ pull --session  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ 6. FINALIZE     │◀───│ 5. APPLY        │◀───│ 4. REVIEW       │
│ Report results  │    │ User approves:  │    │ Present patch   │
│ Update memory   │    │ git apply patch │    │ Wait for OK     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Command Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `jules new --repo <repo> "task"` | Create session | `jules new --repo user/repo "write tests"` |
| `jules remote list --session` | List all sessions | Check status of all tasks |
| `jules remote status --session <ID>` | Check specific session | Get detailed progress |
| `jules remote tail --session <ID>` | Stream live logs | Watch Jules work in real-time |
| `jules remote pull --session <ID>` | Download result | Get the generated code |
| `jules remote pull --session <ID> --apply` | Pull and auto-apply | ⚠️ **DANGEROUS - Never use** |

## Critical Rules

### 🚫 NEVER Auto-Apply
- **ALWAYS** present the patch to the user first
- **ALWAYS** wait for explicit approval before applying
- **ALWAYS** run verification after applying

### ✅ Required Verification
Before reporting success:
1. Check patch contents are reasonable (no malicious code)
2. Verify syntax if applicable (shellcheck for bash, python -m py_compile for Python, etc.)
3. Confirm file paths match expected structure
4. Report any errors or warnings found

### 📋 Error Handling
If Jules fails or produces errors:
1. Capture the full error message
2. Analyze root cause
3. Present to user with options:
   - Retry with clearer instructions
   - Escalate to Minis for manual handling
   - Log failure and abort

## Scripts

### jules_delegate.sh
Main delegation pipeline. Usage:
```bash
jules_delegate.sh "write a Python function to parse JSON" [owner/repo]
```

Features:
- Automatic `--repo` flag handling
- Session ID tracking
- Polled completion waiting
- Patch extraction and reporting
- Colorized output with progress indicators

### jules_status.sh
Quick status checker. Usage:
```bash
jules_status.sh              # Check last session
jules_status.sh --last       # Same as above
jules_status.sh <ID>         # Check specific session
jules_status.sh --help       # Show usage
```

## Examples

### Example 1: Simple Function
```
User: "Ask Jules to write a Python function that validates email addresses"

Minis:
  jules_delegate.sh "write a Python function that validates email addresses" Chieji/myrepo
  → Session 1234567 created
  → Polling every 10s...
  → Completed in 3m 12s
  → Patch saved to jules_work/jules_1234567.patch

Minis: [presents patch contents]

Minis: "Ready to apply? (yes/no/review)"
```

### Example 2: Complex Task with Custom Repo
```
User: "Use Jules to build the authentication module in my webapp"

Minis:
  jules_delegate.sh "build authentication module with login, signup, JWT handling" Chieji/webapp
  → Session 7654321 created
  → Polling every 10s...
  → Completed in 8m 45s
  → Patch: 3 files changed, 156 insertions(+)

Minis: [shows summary of changes]

Minis: "The changes look good. Apply now?"
```

### Example 3: Checking Status
```
User: "What did Jules do on the API task?"

Minis:
  jules_status.sh
  → Session 5555555: Completed 2m ago
  → Duration: 4m 30s
  → Patch available

Minis: "Jules finished! The patch is ready for review."
```

## Repository

- **GitHub**: https://github.com/Chieji/jules-subagent-skill
- **License**: MIT
- **Version**: 1.0.0

## Requirements

- `jules` CLI installed and authenticated
- GitHub account with Jules access
- Active repository connected to Jules

## See Also

- [README.md](README.md) - Installation and quick start
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [tests/](tests/) - Test suite
