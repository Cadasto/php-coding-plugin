# Testing and Validation

This is a content repository: JSON manifests, Markdown components, two shell hooks, a reference PHP config, and a Python validator. There is no build step. Testing means validating structure, then confirming the reference config is one the named tools accept.

## Validation

- **Manifest / component validation** — `./scripts/validate.sh` (also run by CI): both `plugin.json` manifests, dual-host parity, declared paths, kebab-case names, hook JSON, and frontmatter (`name` equals the directory or filename, agents declare `tools:` and not `allowed-tools:`, descriptions fit 1,024 characters). It also checks that every `php-coding` reference is linked from the index, that the Cursor rule names every reference, and that the Cursor rule and agents name only references that exist. If Python 3 is missing the wrapper warns and exits 0. CI installs Python 3 and runs `python3 scripts/validate.py` directly.
- **Official validator** — `claude plugin validate .` checks the manifest and the hook config. Fix its warnings as well as its errors. CI does not run it. It does not catch an unquoted `: ` in frontmatter; only `scripts/validate.py` does.
- **Reference config** — in a scratch project, copy `references/php-cs-fixer.php` to `.php-cs-fixer.php` and `references/phpstan.neon` to `phpstan.neon`, then run `vendor/bin/php-cs-fixer fix --dry-run --diff` and `vendor/bin/phpstan analyse`. Rector, only if you opted in: `vendor/bin/rector process --dry-run --config=rector.php`, then the fixer again.

Checked 2026-09-30 against php-cs-fixer 3.95.27 (`describe @PER-CS` prints `@PER-CS3x0`), PHPStan 2.2.16, PHPUnit 12.5.37, and Rector 2.6.7. The fixer rewrote a missing `declare(strict_types=1)` and the brace layout, and left `==`, an empty `catch`, and a line past 120 characters alone. PHPStan level 8 with `phpVersion: 80400` reported a `string|null` passed to `strlen` and an implicitly nullable parameter, and did not report the `==` or the empty `catch`. Rector's PHP 8.4 set loaded and rewrote only the implicitly nullable parameter.

## Hook smoke tests

Both scripts always exit 0. Run them from the root of a PHP project, with `P` set to this repo's path:

```bash
P=/path/to/php-coding-plugin
bash "$P/hooks/session-start.sh"                                                     # one standards line; nothing outside a PHP workspace
printf '{"tool_input":{"file_path":"src/Foo.php"}}' | bash "$P/hooks/format-on-save.sh"   # Claude Code payload
printf '{"file_path":"/abs/path/src/Foo.php"}' | bash "$P/hooks/format-on-save.sh"          # Cursor afterFileEdit payload
```

With a `.php-cs-fixer.php` and a fixer binary present, the named file is reformatted. Without either, nothing happens.

## Eval suite

`evals/` holds cases for `claude plugin eval` ([docs](https://code.claude.com/docs/en/plugin-evals)). Each case runs three times with the plugin and three times without, and reports both scores and the difference.

```bash
claude plugin eval . --trust-plugin                            # the whole suite, with a no-plugin baseline
claude plugin eval . --trust-plugin --case 'review-*' --runs 1  # one quick pass while editing a case
claude plugin eval . --trust-plugin --ablation none            # with-arm only, half the cost
```

Every run is a full Claude session on your own credential, so the whole suite costs real model calls. Results land in `evals/results/`, which is gitignored.

## Local triggering tests

Load a working copy (see [install.md](install.md)), then:

- **Session-start hook** — open a repo with `composer.json` or a `*.php` file; one standards line should print.
- **`php-coding` index** — ask which standard applies; it should name a command and a reference.
- **References** — a type question or an empty `catch` reads `idioms.md`, a test reads `testing.md`, a PDO query built from input reads `security.md`, a Guzzle call reads `guzzle.md`, a change to a published interface reads `compatibility.md`. The transcript shows the `Read` of the reference file.
- **`php-reviewer`** — a review request loads `php-coding`, reads the references the diff maps to, returns severity-ranked findings, and does not edit or spawn agents.
- **`/php-lint-setup`** — writes the reference config and does not overwrite an existing file unprompted.
- **Cursor rule** — open a `.php` file and confirm `php-context.mdc` attaches.
- **Cursor hooks** — in a PHP workspace other than this repo, confirm the session-start line prints and a `.php` edit is reformatted. Cursor does not document how a plugin hook's relative command path resolves, so this is the only check that it works.

After editing content, reinstall or restart the session.
