# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

- Keep a Changelog: https://keepachangelog.com/en/1.1.0/
- Semantic Versioning: https://semver.org/spec/v2.0.0.html

## [Unreleased]

### Added
- Validator: `scripts/validate.py` fails a `hooks/cursor-hooks.json` without `"version": 1` or with `${CLAUDE_PLUGIN_ROOT}`.

### Fixed
- Hooks: on Cursor, `session-start.sh` and `format-on-save.sh` read the workspace from `CURSOR_PROJECT_DIR`, not the plugin install, and stay silent without it.
- Hooks: on Cursor, `session-start.sh` returns its line as JSON `additional_context` and names `/php-coding`.
- Hooks: `hooks/cursor-hooks.json` declares `"version": 1` and a `timeout` per hook.

## [0.2.0] - 2026-10-19

### Changed
- Agents: `php-reviewer` follows the agent description form (typical triggers, a *When to invoke* section) and reviews only `.php` files and `composer.json`, naming the other files in a diff, unread, in its closing line.

## [0.1.0] - 2026-10-01

Initial plugin. Pin is PHP 8.4. Current stable recorded as PHP 8.5.11; 8.5 features are hints. Style is PER Coding Style 3.1.

### Added
- Skills: `php-coding` index with references `style`, `idioms`, `testing`, `security`, `compatibility`, `psr`, `guzzle`, `monolog`, `opentelemetry`, `slim`, `symfony-components`.
- Skills: `/php-lint-setup` writes `.php-cs-fixer.php` (`@PER-CS` plus `declare_strict_types`) and `phpstan.neon` (level 8, `phpVersion: 80400`). Rector is optional and default-off.
- Agent: `php-reviewer`, report-only, loads `php-coding` through the Skill tool.
- Cursor rule: `rules/php-context.mdc` for `**/*.php`, mirroring the index.
- Hooks: `session-start.sh` names the library references that match `composer.json`; `format-on-save.sh` runs php-cs-fixer on the edited file. Wired for Claude Code and Cursor.
- References: `references/php-cs-fixer.php`, `references/phpstan.neon`, `references/rector.php`.
- Evals: twelve `claude plugin eval` cases, each grading the answer, the skill trigger, and the reference read.
- Validator: `scripts/validate.py` checks manifests and parity, kebab-case names, frontmatter, description length, reference links and orphans, and the Cursor rule mirror.
