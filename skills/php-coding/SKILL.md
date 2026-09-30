---
name: php-coding
description: Use whenever a task writes, reviews, edits, refactors, or debugs PHP code, a .php file, a PHPUnit test, or composer.json dependencies, including a code review of pasted PHP, even when the user does not mention standards. PHP coding standards for PHP 8.4 and later, with 8.5 features as hints, PER Coding Style 3.1 through php-cs-fixer @PER-CS, PHPStan level 8, PHPUnit 12. It routes each change to the command to run and a reference to read, covering style, types and exceptions and modern idioms, PHPUnit testing, security, backward compatibility of a public API, the PSR interfaces (PSR-3, 6, 7, 11, 14, 15, 16, 17, 18, 20), the Guzzle HTTP client, Monolog logging, OpenTelemetry tracing and metrics, Slim 4 apps, and Symfony components used standalone (Console, Process, Yaml, HttpFoundation, EventDispatcher, Cache, Dotenv). Not for Laravel framework code (Laravel Boost covers it), full-stack Symfony configuration, WordPress, Drupal, or Pest.
---

# php-coding — PHP standards index

- **Deterministic beats prose.** Whatever php-cs-fixer, PHPStan, PHPUnit, or `composer audit` fails the build for, run the tool. The references hold only what a green run can still ship, each with its source.
- **The pin is PHP 8.4.** Features that need 8.5 are hints until `composer.json` requires them.

## Route the change

Map every concern the change touches to a row below. Read each mapped reference before editing, and skip the rest. The files live in this skill's `references/` directory.

| The change touches | Run | Read |
|---|---|---|
| layout, naming, line length, side effects in a declaring file, `switch` or closure or array formatting | `vendor/bin/php-cs-fixer fix --dry-run --diff` | [style.md](references/style.md) |
| a type, `mixed`, a union, `never`, an array shape, a generic, `==`, `throw` or `catch`, an enum, `readonly`, a date, `match`, an 8.4 or 8.5 feature | `vendor/bin/phpstan analyse` | [idioms.md](references/idioms.md) |
| a test, a data provider, a coverage attribute, a fixture, a guard that rejects input | `vendor/bin/phpunit` | [testing.md](references/testing.md) |
| a public or protected class, interface, method signature, property, or constant that other packages use | `vendor/bin/roave-backward-compatibility-check` | [compatibility.md](references/compatibility.md) |
| SQL, HTML output, passwords, tokens, `unserialize`, shell commands, file paths or URLs from input, XML, sessions | `composer audit` | [security.md](references/security.md) |
| a PSR interface, with or without the `Psr\` prefix in view: `ServerRequestInterface`, `ResponseInterface`, `MiddlewareInterface`, `RequestHandlerInterface`, `LoggerInterface`, `ContainerInterface`, `ClientInterface`, `ClockInterface`, a PSR-6 or PSR-16 cache, a PSR-14 dispatcher, a PSR-17 factory | `vendor/bin/phpstan analyse` | [psr.md](references/psr.md) |
| `GuzzleHttp\` | none | [guzzle.md](references/guzzle.md) |
| `Monolog\` | none | [monolog.md](references/monolog.md) |
| `OpenTelemetry\` | none | [opentelemetry.md](references/opentelemetry.md) |
| a Slim 4 app: `Slim\`, `AppFactory`, the PHP-DI bridge, route and middleware setup | none | [slim.md](references/slim.md) |
| a Symfony component used on its own: Console, Process, Yaml, HttpFoundation, EventDispatcher, Cache, Dotenv | none | [symfony-components.md](references/symfony-components.md) |
| `.php-cs-fixer.php`, `phpstan.neon`, `rector.php` | none | run `/php-lint-setup` |

The session-start hook names the library references that match `composer.json`. A subagent does not inherit loaded skills, so an orchestrator puts this table, or the references to read, into every implementer and reviewer brief.

## Minimum checklist

Apply these even when no reference is read:

- Run `vendor/bin/php-cs-fixer fix --dry-run --diff` and `vendor/bin/phpstan analyse`. Do not hand-apply a rule either tool decides.
- Every PHP file has `declare(strict_types=1);`. Compare with `===` and `!==`.
- Do not swallow an exception. Chain the previous one when you translate it.
- Bind SQL parameters. Escape output for the context it lands in.
- Every guard has a test that fails when the guard is removed.

## Tie-breaks and review

When both forms pass the tools, pick the form a reference cites and name the rule that decided it. "More idiomatic" alone is not a reason.

For a focused review, dispatch the `php-reviewer` agent. It reports and never edits. If a workflow already owns the review seat, that reviewer reads these references itself; do not run `php-reviewer` beside it.

Anything a person reads, such as a PR description or a review comment, goes in plain English, with the effect before the mechanism.
