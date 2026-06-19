# Jules Sub-Agent Skill

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/Chieji/jules-subagent-skill)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Skill](https://img.shields.io/badge/minis-skill-ready-success)](https://github.com/ClauHaus/Minis)

> Delegate coding tasks to **Google's Jules** — the asynchronous AI coding agent — with full visibility, review, and verification.

---

## What is This?

A Minis skill that enables seamless integration with [Jules](https://jules.google.com) — Google's asynchronous coding agent. Instead of waiting for code in real-time, delegate to Jules and let it work in the background while you do other things.

### Key Features

- 🚀 **One-command delegation** — Create Jules sessions from Minis chat
- ⏳ **Automatic polling** — Wait for Jules to finish without blocking
- 📝 **Patch review** — Always review before applying (no auto-merge)
- 🔧 **GitHub integration** — Works with any connected repo
- ✅ **Verification pipeline** — Test before you trust

---

## Installation

### Prerequisites

- [Jules CLI](https://jules.google.com) installed and authenticated
- GitHub account with [Jules access](https://jules.google.com)
- Minis environment

### Install via ClawHub

```bash
clawhub install jules-subagent
```

### Manual Install

```bash
# Clone to your skills directory
git clone https://github.com/Chieji/jules-subagent-skill.git \
  /var/minis/skills/jules-subagent

# Make scripts executable
chmod +x /var/minis/skills/jules-subagent/scripts/*.sh
```

---

## Quick Start

### 1. Delegate a Task

```bash
# Using the skill from Minis
"Ask Jules to write a Python function that validates email addresses"

# Or use the script directly
./scripts/jules_delegate.sh "write a Python function that validates email addresses"
```

### 2. Check Status

```bash
./scripts/jules_status.sh
# or specify a session ID
./scripts/jules_status.sh 2638064033004501342
```

### 3. Review & Apply

```bash
# View the patch
cat /var/minis/workspace/jules_work/jules_*.patch

# Apply if satisfied
git apply /var/minis/workspace/jules_work/jules_*.patch
```

---

## Usage Examples

### Example 1: Write a Function

```bash
./scripts/jules_delegate.sh "Write a Python function to check if a number is prime"
```

Output:
```
🚀 Creating Jules session...
   Task: Write a Python function to check if a number is prime
   Repo: Chieji/jules-subagent-skill

📋 Session created: 2638064033004501342
⏳ Waiting for Jules to complete...
   ...still working (session: 2638064033004501342)
   ...still working (session: 2638064033004501342)

📥 Jules finished! Pulling result...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ Jules Session Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Task:       Write a Python function to check if a number is prime
  Session ID: 2638064033004501342
  Patch:      /var/minis/workspace/jules_work/jules_2638064033004501342.patch
  Lines:      28

  ⚠️  Review the patch before applying:
      cat /var/minis/workspace/jules_work/jules_2638064033004501342.patch
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Example 2: Use a Different Repository

```bash
./scripts/jules_delegate.sh "add unit tests for utils.py" Chieji/my-project
```

---

## Project Structure

```
jules-subagent-skill/
├── SKILL.md                    # Skill definition & workflow
├── setup.yaml                  # Configuration & metadata
├── README.md                   # This file
├── LICENSE                     # MIT License
├── CHANGELOG.md               # Version history
├── scripts/
│   ├── jules_delegate.sh      # Main delegation pipeline
│   └── jules_status.sh        # Status checker
└── tests/
    ├── test_jules_delegate.sh  # Delegate tests
    └── test_jules_status.sh   # Status tests
```

---

## How It Works

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   You Ask   │────▶│  Minis Agent │────▶│ Create Task │
│  "Ask Jules"│     │   (Skill)    │     │   (Jules)   │
└─────────────┘     └──────────────┘     └─────────────┘
                                                  │
                          ┌────────────────────────┘
                          ▼
                   ┌──────────────┐
                   │ Jules Works  │
                   │  (Async)     │
                   └──────────────┘
                          │
                          ▼
                   ┌──────────────┐
                   │ Pull Result  │
                   │  (Patch)     │
                   └──────────────┘
                          │
                          ▼
                   ┌──────────────┐
                   │   Review     │◀────── Always review first!
                   └──────────────┘
                          │
                   ┌──────┴──────┐
                   ▼             ▼
            ┌──────────┐   ┌──────────┐
            │ Approve  │   │ Reject   │
            │ (Apply)  │   │ (Retry)  │
            └──────────┘   └──────────┘
```

---

## Configuration

### Default Repository

Set your default repository in the script:

```bash
# In jules_delegate.sh, change this line:
REPO="${2:-Chieji/jules-subagent-skill}"
```

### Workspace Directory

Patches are saved to:
```bash/var/minis/workspace/jules_work/
```

Change in scripts if needed.

---

## Safety & Security

> ⚠️ **CRITICAL RULE: Never auto-apply Jules output**

This skill **always** requires manual review before applying patches. This protects you from:
- Security vulnerabilities
- Unexpected file modifications
- Code that doesn't meet your standards

### Review Checklist

Before applying any patch:
- [ ] Read the patch content
- [ ] Check what files are modified/created
- [ ] Look for security issues (evals, shell exec, hardcoded secrets)
- [ ] Run tests if available
- [ ] Apply only when satisfied

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `No --repo flag provided` | The script now auto-uses your default repo |
| Session never finishes | Check `jules remote list --session` for status |
| Pull is empty | Session may still be running or failed |
| Patch fails to apply | Manual review needed — may need re-delegation |
| Auth errors | Run `jules login` to re-authenticate |

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Acknowledgments

- [Google Jules](https://jules.google.com) — The async coding agent
- [Minis](https://github.com/ClauHaus/Minis) — The agent runtime environment
- [ClawHub](https://clawhub.com) — Skill registry and distribution

---

<p align="center">Made with 🔥 by <a href="https://github.com/Chieji">Chieji</a></p>