# Skill, Reference, Command, Agent, and Rule Authoring Conventions

The detailed companion to [AGENTS.md](../AGENTS.md), which is authoritative. This file expands on the *how*. The shipped components are the reference examples.

## Layout

- **One knowledge skill.** `skills/php-coding/SKILL.md` is the index. Its topics live in `skills/php-coding/references/<topic>.md`. This follows the progressive-disclosure pattern in Anthropic's [skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices): only the index description is always on, and a reference costs nothing until it is read.
- **One command skill.** `skills/php-lint-setup/SKILL.md` stays separate because it is a user-invoked slash command with `argument-hint` and `allowed-tools`.
- `agents/<name>.md` for agents, `rules/<name>.mdc` for Cursor rules, `evals/<case>/` for eval cases. Shared lint config lives in the top-level `references/`, which is a different directory from the skill's `references/`. The legacy `commands/<name>.md` layout is not used.
- Components are kebab-case and namespaced `php-coding:<component>`. A component's frontmatter `name` MUST equal its directory (skills) or filename stem (agents); `scripts/validate.py` enforces this.

## Skill, reference, agent, rule

- **Index skill.** Always-on `description`, then a routing table: what the change touches, the command to run, the reference to read. Keep it short; the rules belong in the references.
- **Reference file.** No frontmatter. Shape: `# Title`, one `Read when:` line naming the packages, namespaces, functions, or situations that apply, a backstop line naming the command (or saying there is none), `## Rules` as bullets with a bold lead and an inline source link, and `## Sources`. Keep it at 100 lines or fewer; past 100 it needs a `## Contents` list. Mention another reference by its basename in backticks (`see psr.md`), never by a nested link chain.
- **Command skill.** A thin one-shot `SKILL.md` with `argument-hint` and `allowed-tools`, using `$ARGUMENTS` in the body. See `/php-lint-setup`.
- **Agent.** A context-isolated specialist. Use **`tools:`**, **never** `allowed-tools:`. Include `Skill` in `tools:` when the agent must load `php-coding`, because a subagent does not inherit the parent's loaded skills. See `php-reviewer`.
- **Cursor rule.** A Cursor-only `.mdc` with `description`, `globs`, and `alwaysApply` that mirrors the index table. See `rules/php-context.mdc`.

## The `description` (the trigger)

The index description is the only always-on text, so it carries the trigger words for every reference: third person, what it covers, when to load it, and a short "Not for …". The Agent Skills limit is 1,024 characters; `scripts/validate.py` enforces it.

**YAML gotcha:** a `description` value with an unquoted `: ` (colon-space) or ` #` is invalid YAML (YAML 1.2.2, section 7.3.3). `scripts/validate.py` guards against it; `claude plugin validate` does not. Reword or quote the value.

## Body rules

- **Deterministic beats prose.** If php-cs-fixer `@PER-CS`, PHPStan level 8, PHPUnit, or `composer audit` fails the build when the rule is broken, name the command and do not restate the rule.
- If a model can ship the wrong form with a green run, the rule belongs in a reference, with a citation to a primary source: the PER or PSR text, the PHP manual, the library's own docs, or its source at a release tag.
- If neither is true, leave it out. No generic advice, and no second prose style guide.
- Keep time-sensitive wording out of rules. A "checked" date belongs in `## Sources` or in AGENTS.md, not in an instruction.
- In scope: framework-neutral PHP, the PSR interfaces, Guzzle, Monolog, OpenTelemetry, Slim, and standalone Symfony components. Out of scope: Laravel framework code (Laravel Boost), full-stack Symfony configuration (bundles, `config/packages`, Doctrine), WordPress, Drupal, and Pest.

## The rule test

Applied to every line:

1. The broken form fails `vendor/bin/php-cs-fixer fix --dry-run --diff`, `vendor/bin/phpstan analyse`, or `composer audit`: name the command, do not restate.
2. A green run can ship the wrong form, and a citation exists: the reference states the rule and cites the source.
3. Otherwise: leave it out.

## Adding a reference

1. Write `skills/php-coding/references/<topic>.md` in the shape above.
2. Add a row to the index table in `SKILL.md` and extend its `description` with the trigger words.
3. Add it to the table in `rules/php-context.mdc`.
4. If it covers a library, add the package to the session-start hook's detection.
5. If `php-reviewer` should check it, name it in a review dimension.
6. Add at least one eval case under `evals/`.
7. Run `./scripts/validate.sh`. It fails if a reference is not linked from the index or is missing from the Cursor rule.

## Eval cases

Each case is a directory with `prompt.md` and a `graders/` folder ([plugin evals](https://code.claude.com/docs/en/plugin-evals)). Write the prompt the way a user would, without naming the skill, and inline any code, since each run starts in an empty directory. Give each case three graders: an `llm` grader with concrete PASS and FAIL conditions, a `tool_used` grader that checks `php-coding` fired, and a `tool_used` grader on `Read` with `arm: with-only` that checks the right reference was read.

## Dual-host parity

Skills and agents are shared. The **Cursor** manifest (`.cursor-plugin/plugin.json`) declares each component path. **Claude** discovers the default folders automatically. Keep `name`, `version`, `description`, and `author` identical across the two manifests. The Claude hook command quotes the placeholder (`bash "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"`). The Cursor hook command is workspace-relative (`bash hooks/session-start.sh`), never `${CLAUDE_PLUGIN_ROOT}`.

## Before committing

Run `./scripts/validate.sh` and `claude plugin validate .`. When you add or rename a reference or component, follow **Adding a reference** above and sync **AGENTS.md**, **README.md**, **CHANGELOG.md**, and the triggering tests in [testing.md](testing.md).
