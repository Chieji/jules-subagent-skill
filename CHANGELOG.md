# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-06-20

### Added
- Initial release of Jules Sub-Agent Skill
- `jules_delegate.sh` — Full pipeline for creating, polling, and pulling Jules sessions
- `jules_status.sh` — Quick status checker for Jules sessions
- Comprehensive README with usage examples and architecture diagrams
- SKILL.md with trigger conditions and workflow documentation
- setup.yaml with skill metadata and configuration
- MIT License
- Test suite scaffolding

### Features
- One-command delegation to Jules async coding agent
- Automatic polling with progress updates
- Patch review workflow (no auto-apply for safety)
- Support for custom repositories via `--repo` flag
- Session ID tracking and history
- Configurable workspace directory
- Comprehensive error handling and user feedback

### Security
- **Critical**: Never auto-applies Jules output — always requires manual review
- Validates all inputs before sending to Jules
- Safe file operations with proper path handling

---

## Planned for Future Releases

### [1.1.0] — Enhanced Integration
- [ ] Add support for batch delegation (multiple tasks)
- [ ] Integration with Minis memory system for session history
- [ ] Automatic test execution after patch application
- [ ] Webhook support for Jules completion notifications

### [1.2.0] — Advanced Features
- [ ] Session comparison (diff between Jules iterations)
- [ ] Custom verification scripts per project
- [ ] Integration with GitHub Actions for CI/CD
- [ ] Support for private package registries

### [2.0.0] — Platform Expansion
- [ ] Support for other async coding agents (Codex, etc.)
- [ ] Multi-agent orchestration (Jules + others)
- [ ] Enterprise features (SSO, audit logs)

---

## Contributing

When adding changes, follow this format:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes to existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Now removed features

### Fixed
- Bug fixes

### Security
- Security improvements
```