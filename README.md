# PHP Coding Plugin

An AI plugin by **Cadasto B.V.** that teaches AI coding assistants **idiomatic PHP**: the PER Coding Style rules a fixer does not settle, types, exceptions, PHP 8.4 idioms, PHPUnit, security, the PSR interfaces, and the libraries most PHP services lean on (Guzzle, Monolog, OpenTelemetry, Slim, and standalone Symfony components). It ships one skill with reference files, a slash command, a reviewer agent, session-start and format-on-save hooks, and a Cursor rule. It targets **both Claude Code and Cursor** from a single shared component set.

The language pin is **PHP 8.4**. Current stable, checked 2026-09-30, is **PHP 8.5.11**, so features that need 8.5 are hints. Laravel framework code is out of scope; [Laravel Boost](https://github.com/laravel/boost) covers it.

## Install

**Claude Code** — from the Cadasto marketplace:

```
/plugin marketplace add Cadasto/plugin-marketplace
/plugin install php-coding@cadasto
```

Or load a local working copy for one session: `claude --plugin-dir /path/to/php-coding-plugin`.

**Cursor**: add this repository as a plugin (Settings → Plugins). See [`docs/install.md`](docs/install.md).

**Prerequisites** — the plugin installs without a PHP toolchain. Enforcement expects **PHP 8.4+** (8.5 is current stable), plus `php-cs-fixer`, PHPStan, and PHPUnit on the project. Rector is optional and off by default. See [Host toolchain](docs/install.md#host-toolchain).

## Component surface

| Component | Purpose |
|-----------|---------|
| Skill `php-coding` | Auto-invoked index. Routes each change to the command to run and the reference to read. |
| `php-coding` references | `style`, `idioms`, `testing`, `security`, `compatibility`, `psr`, `guzzle`, `monolog`, `opentelemetry`, `slim`, `symfony-components`. Each holds only rules a green php-cs-fixer and PHPStan run can still miss, with sources. |
| Skill `/php-lint-setup` | Writes the reference php-cs-fixer and PHPStan config. Rector only if asked. |
| Agent `php-reviewer` | Report-only reviewer for what the tools miss. Loads `php-coding` and reads the references the diff needs. No edits, no sub-agents. |
| Session-start hook | Detects a PHP workspace, prints one standards line, and names the library references that match `composer.json`. |
| Format-on-save hook | After a `*.php` edit, runs `php-cs-fixer fix` on that file when a project config and a binary exist. Silent no-op otherwise. |
| Reference config | `references/php-cs-fixer.php` (`@PER-CS` plus `declare_strict_types`), `references/phpstan.neon` (level 8, `phpVersion: 80400`), `references/rector.php` (optional). |
| Cursor rule `php-context.mdc` | `**/*.php` mirror of the `php-coding` index. |
| Eval suite `evals/` | Cases for `claude plugin eval`, each checking the answer, that the skill fired, and that the right reference was read. |

Style is [PER Coding Style 3.1](https://www.php-fig.org/per/coding-style/). PSR-12 is the frozen baseline that PER still accepts, not a second guide. The fixer ruleset is [`@PER-CS`](https://cs.symfony.com/doc/ruleSets/PER-CS.html), which on 2026-09-30 still aliased the PER 3.0 set, so the `style` reference lists the 3.1 additions to follow by hand.

## Development

No build step. The plugin is Markdown and JSON, plus reference PHP config, two shell hooks, and a Python validator. Validate locally:

```bash
./scripts/validate.sh                 # dual-host parity, frontmatter, reference links (soft-skips if python3 is absent)
claude plugin validate .              # manifest + hooks
claude plugin eval . --trust-plugin   # behaviour: runs evals/ with and without the plugin
```

See [`docs/testing.md`](docs/testing.md) and [`AGENTS.md`](AGENTS.md).

## License

[MIT](LICENSE)
