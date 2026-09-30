# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

- Keep a Changelog: https://keepachangelog.com/en/1.1.0/
- Semantic Versioning: https://semver.org/spec/v2.0.0.html

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
