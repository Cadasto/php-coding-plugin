# AI Guidelines: PHP Coding Plugin

This file provides guidance to AI coding assistants (Claude Code, Cursor, and compatible tools that read `AGENTS.md`) working in this repository. It is the **canonical** instruction set. `.claude/CLAUDE.md` imports it with `@../AGENTS.md`, and any host-specific instruction file defers to it.

## Project Overview

The **PHP Coding Plugin** is an AI plugin by Cadasto B.V. that teaches AI coding assistants **idiomatic PHP**: the PER rules a fixer does not settle, types, exceptions, modern idioms, PHPUnit, security, the PSR interfaces, and the libraries PHP services lean on (Guzzle, Monolog, OpenTelemetry, Slim, standalone Symfony components). It targets **both Claude Code and Cursor** from a single shared component set.

> **Current status: v0.1.0, released 2026-10-01.** One knowledge skill, `php-coding`, is an index over eleven reference files. Beside it are the `/php-lint-setup` command skill, the report-only `php-reviewer` agent, the `rules/php-context.mdc` Cursor rule, `session-start` and `format-on-save` hooks, the reference lint config, and an eval suite. Everything passes `./scripts/validate.sh`. Do not assume a file is present because it is documented here. Check first.

## Domain Context

Guidance is grounded in sources read on 2026-09-30, not in memory:

- **Language pin — PHP 8.4.** The Cadasto template-repo requires `"php": "^8.4"`. PHP 8.4 is in active support until 31 Dec 2026 (latest patch that day: 8.4.26). — <https://www.php.net/supported-versions.php>
- **Current stable — PHP 8.5.11** (24 Sep 2026). Features that need 8.5 are hints until a repo requires them. PHP 8.6 was a release candidate and is not a target. — <https://www.php.net/releases/8_5_11.php>
- **PER Coding Style 3.1** (tagged 13 Aug 2026) is the living standard. It extends and replaces PSR-12, which stays the frozen baseline PER still accepts. — <https://www.php-fig.org/per/coding-style/>, <https://github.com/php-fig/per-coding-style/blob/3.1.0/migration-3.1.md>
- **php-cs-fixer `@PER-CS`** aliases the newest set the fixer ships, `@PER-CS3x0` (PER 3.0), in php-cs-fixer 3.95.27. There is no 3.1 set yet, so `style.md` lists the 3.1 additions to follow by hand. — <https://cs.symfony.com/doc/ruleSets/PER-CS.html>
- **PHPStan level 8** (cumulative; level 8 adds nullable access). `phpVersion: 80400` is PHP 8.4. PHPStan has no taint analysis. — <https://phpstan.org/user-guide/rule-levels>
- **PHPUnit 12.5**, the line the template-repo requires. PHPUnit 12.0 removed doc-comment metadata, so only attributes count. Pest is out of scope. — <https://docs.phpunit.de/en/12.5/>, <https://github.com/sebastianbergmann/phpunit/releases/tag/12.0.0>
- **Compatibility**: SemVer 2.0.0 and Symfony's backward compatibility promise define a break; `roave/backward-compatibility-check` 8.22.0 detects one. — <https://symfony.com/doc/current/contributing/code/bc.html>
- **Libraries** (latest stable that day): Guzzle **8.2.0**, with 7.15.x still patched; Monolog **3.12.1**; OpenTelemetry PHP api 1.10.0 and sdk 1.15.0, with traces, metrics, and logs all stable; Slim **4.15.3**, with no Slim 5 release; Symfony **8.1**, whose components require PHP **8.4.1**, and 7.4 LTS on PHP 8.2+; `psr/http-message` 2.0 and `psr/log` 3.0. Each reference cites its own release tag.
- **Skill format** follows Anthropic's skill authoring best practices: an always-on description of at most 1,024 characters, a short SKILL.md, and reference files one level deep, with a table of contents past 100 lines. — <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>

Decisions taken from the template-repo, and the ones this plugin does not copy:

- Kept: PHP `^8.4`, `declare(strict_types=1)` on every file, PHPStan level 8, PHPUnit 12.
- Not copied: PHPCS with a PSR-12 ruleset (`@PER-CS` already includes `@PSR12`). `treatPhpDocTypesAsCertain: false` (it relaxes checks). Rector `deadCode` and `codeQuality` as a default (Rector is optional, pinned to PHP 8.4, and the fixer runs after it).

Scope: framework-neutral PHP, the PSR interfaces, Guzzle, Monolog, OpenTelemetry, Slim, and Symfony components used standalone. Out of scope: Laravel framework code ([Laravel Boost](https://github.com/laravel/boost) covers it), full-stack Symfony configuration, WordPress, Drupal, and Pest.

When a recommendation derives from a source, attribute it. A rule the fixer, PHPStan, or `composer audit` already fails the build for is a command, not a paragraph.

### Refreshing a dated fact

The facts above are copied into the README, the testing doc, the index description, the references, the agent, the Cursor rule, the session-start line, and the reference config comments. When one changes, re-read the source, then list every copy:

```bash
grep -rnE '8\.5\.[0-9]+|8\.4\.[0-9]+|current stable|PER Coding Style 3|PER-CS3x0|12\.5|Guzzle [78]|Monolog 3|Slim 4|Symfony [78]|2026-09-30' --exclude-dir=.git --exclude-dir=evals --exclude=CHANGELOG.md .
```

Update each hit. Keep release numbers and "checked" dates in `## Sources` sections and in this file, not in rule text. Leave released CHANGELOG sections as they are.

## Repository Layout

- **Claude manifest**: `.claude-plugin/plugin.json` — `name`, `version`, `description`, `author` (an **object** `{name, url}`), `license`, `repository`, `keywords`. Claude Code discovers `skills/`, `agents/`, and `hooks/` automatically.
- **Cursor manifest**: `.cursor-plugin/plugin.json` — the same metadata **plus** explicit path keys (`skills`, `rules`, `agents`, `hooks`). No `mcpServers`. Keep `name`, `version`, `description`, and `author` identical to the Claude manifest.
- **Knowledge skill**: `skills/php-coding/SKILL.md` is the index: principles, a routing table from "what the change touches" to a command and a reference, and a minimum checklist. Its references are `skills/php-coding/references/`: `style`, `idioms`, `testing`, `security`, `compatibility`, `psr`, `guzzle`, `monolog`, `opentelemetry`, `slim`, `symfony-components`.
- **Command skill**: `skills/php-lint-setup/SKILL.md` (`/php-lint-setup`), with `argument-hint` and `allowed-tools`. It is separate because it is user-invoked. The legacy `commands/` folder is not used.
- **Agent**: `agents/php-reviewer.md`. Report-only, no sub-agent dispatch. Its `tools:` include `Skill` so it can load `php-coding`.
- **Cursor rule**: `rules/php-context.mdc` (`globs: ["**/*.php"]`) mirrors the index table.
- **Claude hooks**: `hooks/hooks.json` wires `SessionStart` and `PostToolUse` (`matcher: "Write|Edit"`) to the shared scripts as `bash "${CLAUDE_PLUGIN_ROOT}/hooks/<script>.sh"`.
- **Cursor hooks**: `hooks/cursor-hooks.json` wires `sessionStart` and `afterFileEdit` to the same scripts with a workspace-relative command.
- **Shared hook scripts**: `hooks/session-start.sh` detects `composer.json` or a `*.php` file, prints one line, and names the library references whose packages appear in `composer.json` (and Laravel Boost for `laravel/framework`). `hooks/format-on-save.sh` reads the edited path from the host's stdin JSON (`tool_input.file_path` on Claude Code, `file_path` on Cursor) and runs `php-cs-fixer fix` on a `*.php` file when a project config and a fixer binary exist. Both always exit 0.
- **Reference lint config**: top-level `references/php-cs-fixer.php`, `references/phpstan.neon`, `references/rector.php` (Rector optional, default-off). This is a different directory from `skills/php-coding/references/`.
- **Eval suite**: `evals/<case>/` with `prompt.md` and `graders/`, run by `claude plugin eval`. Results go to `evals/results/`, which is gitignored.
- **Validation**: `scripts/validate.sh` wraps the stdlib-only `scripts/validate.py`. CI (`.github/workflows/validate.yml`) installs Python 3 and runs it on pushes to `main` and on pull requests.
- **Contributor docs**: `docs/install.md`, `docs/testing.md`, `docs/versioning.md`, and `docs/authoring.md` (the detailed companion to this file). Local planning or research notes go in `docs/plans/` or `docs/research/`, which are gitignored.
- **MCP config** *(not present)*: no `.mcp.json`. Do not reference one.

## Development

### Testing & validating

No build step. The plugin is Markdown and JSON, plus reference PHP config, two shell hooks, and a stdlib-only Python validator.

```bash
./scripts/validate.sh                  # prints "OK: ..." or "FAIL: N problem(s)"; soft-skips if python3 is absent
claude plugin validate .               # manifest and hooks; fix its warnings as well as its errors
claude --plugin-dir .                  # load this working copy for one session to dogfood it
claude plugin eval . --trust-plugin    # run evals/ with and without the plugin; costs real model calls
bash hooks/session-start.sh            # one standards line in a PHP workspace, nothing elsewhere; exit 0
printf '{"tool_input":{"file_path":"src/Foo.php"}}' | bash hooks/format-on-save.sh; echo $?   # always 0
```

`scripts/validate.py` checks the manifests and their parity, component paths, kebab-case names, hook JSON, and frontmatter. For the knowledge skill it also checks:

- the description fits 1,024 characters;
- every reference is linked from `SKILL.md` and every link resolves;
- a reference past 100 lines has `## Contents`;
- the Cursor rule names every reference;
- the Cursor rule, the agents, and the references name only references that exist.

CI runs only the Python validator. `claude plugin validate .` and the eval suite are local steps. On Cursor, install via its plugin flow and confirm the skill, agent, and rule load. The full procedure is in `docs/testing.md`.

### File Conventions

- All Markdown component files use **YAML frontmatter**, except reference files, which have none. Quote a value that contains `: ` or ` #`, or use a `>` block (see Gotchas).
- A **reference file** is `# Title`, one `Read when:` line, a backstop line naming the command or saying there is none, `## Rules`, and `## Sources`. Each rule is a bold lead plus an inline link to a primary source. Mention another reference by basename in backticks (`see psr.md`).
- Use **kebab-case** for all directory and file names. A component's frontmatter `name` equals its directory (skills) or filename stem (agents).
- `allowed-tools:` pre-approves tools for a skill. Agents declare `tools:` instead (see Gotchas).
- The index `description` is the only always-on text. It carries the trigger words for every reference and ends with what it is not for.
- Use `"${CLAUDE_PLUGIN_ROOT}"`, in double quotes, for intra-plugin paths in Claude hook commands. Never hardcode absolute paths or `~`.

### Adding or changing a reference

Update these in the same change. `scripts/validate.py` fails on the first three if they drift.

- The routing table in `skills/php-coding/SKILL.md`, and its `description` if the trigger words change.
- The table in `rules/php-context.mdc`.
- Any `see <name>.md` mentions in other references and in `agents/php-reviewer.md`.
- The session-start hook's package detection, for a library reference.
- An eval case under `evals/`, with an `llm` grader, a `tool_used: Skill` grader, and a `regex` grader over `trace` that matches a `Read` or `Grep` of the reference path, with `arm: with-only` (models often grep a reference instead of reading it).
- **README.md**, this file, and **CHANGELOG.md** (under `## [Unreleased]` once a release exists).

When a dated version fact changes, follow [Refreshing a dated fact](#refreshing-a-dated-fact).

### Versioning

- Keep `version`, `description`, and `author` **identical in both** manifests. `scripts/validate.py` fails on a mismatch.
- Follow **Semantic Versioning**. The bump table and release steps are in `docs/versioning.md`.

### CHANGELOG style

- Entries accumulate under `## [Unreleased]` and fold into the next `## [X.Y.Z] - YYYY-MM-DD` section at release.
- Use the Keep a Changelog groups in order — **Added, Changed, Deprecated, Removed, Fixed, Security** — omitting empty groups.
- One terse line per bullet; lead with the subsystem. No rationale or PR links.

### Commit Messages & Branching

- Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), e.g. `feat(skills): add the slim reference`.
- Scopes: `skills`, `agents`, `hooks`, `rules`, `evals`, `docs`, and `release` for `chore(release): vX.Y.Z`. A scope is optional in Conventional Commits. Leave it out for a change outside these, such as the validator, CI, or the reference config.
- Use feature branches and pull requests. CI validates every pull request and every push to `main`.

## Gotchas

- **Agents use `tools:`, not `allowed-tools:`.** In an agent file `allowed-tools:` is ignored and the agent silently inherits *all* tools. `scripts/validate.py` fails on `allowed-tools:` and on a missing `tools:`.
- **A subagent does not inherit loaded skills.** `php-reviewer` lists `Skill` in `tools:` and loads `php-coding:php-coding` itself. An orchestrator puts the index table, or the references to read, into every brief. — <https://code.claude.com/docs/en/sub-agents>
- **Two directories are called `references/`.** The top-level one holds lint config that `/php-lint-setup` mirrors. `skills/php-coding/references/` holds the Markdown rules. Do not move one into the other.
- **Keep the two manifests in parity.** Cursor needs explicit path keys. Claude relies on default-folder discovery.
- **Quote `${CLAUDE_PLUGIN_ROOT}` in Claude hook commands.** A plugin path that contains a space splits into several words. `claude plugin validate .` warns on the unquoted form.
- **A Claude hook `timeout` is in seconds, not milliseconds.** The default for a command hook is 600. — <https://code.claude.com/docs/en/hooks>
- **Hook scripts get the edited path from stdin.** Claude Code sends it as `tool_input.file_path` and documents no `CLAUDE_FILE_PATH` variable. Keep the stdin parsing in `format-on-save.sh`.
- **The Cursor hook uses a workspace-relative command** (`bash hooks/session-start.sh`), *not* `${CLAUDE_PLUGIN_ROOT}`. Cursor's plugin docs, checked 2026-09-30, do not say how a plugin hook path resolves. Confirm both hooks fire in a PHP workspace other than this repo.
- **An unquoted `: ` or ` #` in a frontmatter value is invalid YAML** (YAML 1.2.2, section 7.3.3). `scripts/validate.py` is the only check that catches it; `claude plugin validate` passed such a skill in a test on CLI 2.1.283. — <https://yaml.org/spec/1.2.2/#733-plain-style>
- **The fixer lags PER.** `@PER-CS` still means PER 3.0. Do not claim the fixer enforces a 3.1 rule; `style.md` lists them.
- **`AGENTS.md` and `.github/` are export-ignored** in `.gitattributes`. A shipped skill, reference, agent, rule, or hook must not depend on them.
- **Do not restate a rule `@PER-CS`, PHPStan level 8, or `composer audit` already enforces.** Name the command. A reference is only for what a green run can still ship.
- **Rector does not outrank the fixer.** It is optional and default-off. If it runs, php-cs-fixer runs after it.
- **Don't invent a companion MCP server.** There is no `.mcp.json` today.
