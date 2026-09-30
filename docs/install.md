# Installing the PHP Coding Plugin

> This plugin is Markdown and JSON, plus two shell hooks and reference PHP config. There is no build step and **no MCP server** to wire up.

This plugin is distributed for both [Claude Code](https://docs.claude.com/en/docs/claude-code/plugins) (`.claude-plugin/`) and [Cursor](https://cursor.com/docs/plugins) (`.cursor-plugin/`). Skill, agent, and rule content is shared; only the manifest and hook layer differ.

## Claude Code

### Install (from the Cadasto marketplace)

```
/plugin marketplace add Cadasto/plugin-marketplace
/plugin install php-coding@cadasto
```

The marketplace name is `cadasto`, so the plugin is addressed as `php-coding@cadasto`.

### Load a local working copy (development)

```bash
claude --plugin-dir /path/to/php-coding-plugin
```

The flag loads the plugin for that session only. Pass it again in each new session.

### Inspect / update

```bash
claude plugin validate .
claude plugin details php-coding
```

A session restart is required for an update to take effect.

## Cursor

Add this repository as a plugin (Cursor **Settings → Plugins**, via Git URL or local path). The repo root contains `.cursor-plugin/plugin.json`, which declares the `skills`, `agents`, `rules`, and `hooks` paths. After changing content locally, reload or reinstall the plugin so Cursor picks it up.

## Host toolchain

Installing the plugin needs no PHP toolchain. Enforcement does. The pin is **PHP 8.4** (`"php": "^8.4"`). Current stable on 2026-09-30 is **PHP 8.5.11**. A repo on 8.4 must not use 8.5-only syntax; PHPStan `phpVersion: 80400` is what rejects it.

| Tool | Used for | If missing |
|------|----------|------------|
| PHP 8.4+ | running the tools; 8.5.11 is current stable | no toolchain |
| `vendor/bin/php-cs-fixer` | `@PER-CS` plus `declare_strict_types`; the format-on-save hook | hook no-ops; style is not enforced |
| `vendor/bin/phpstan` | level 8, `phpVersion: 80400` | type errors are not enforced |
| `vendor/bin/phpunit` | the `testing` reference | tests are not run |
| Composer 2.4+ | `composer audit`, the `security` reference's backstop | advisories are not checked |
| `vendor/bin/rector` | optional PHP 8.4 modernization | leave it uninstalled; it is default-off |

`/php-lint-setup` writes the reference config. Install the binaries with Composer in the target repo, for example `friendsofphp/php-cs-fixer`, `phpstan/phpstan:^2`, and `phpunit/phpunit:^12.5`. Download PHP from <https://www.php.net/downloads.php>.

The format-on-save hook looks for `.php-cs-fixer.php` (or `.php-cs-fixer.dist.php`) in the working directory and for `vendor/bin/php-cs-fixer` or `php-cs-fixer` on `PATH`. It does not install them.
