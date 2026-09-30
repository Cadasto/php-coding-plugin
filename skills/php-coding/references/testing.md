# Testing — PHPUnit

Read when: writing or reviewing PHPUnit tests, data providers, assertions, coverage attributes, fixtures, or a test for a guard.

Deterministic backstop: `vendor/bin/phpunit`. With `phpstan/phpstan-phpunit` installed, `vendor/bin/phpstan analyse` also reports always-true and always-false assertions at level 4 and above (such as `assertInstanceOf()` on a value whose return type already guarantees the class) and `assertEquals()` between values of the same type ([phpstan-phpunit](https://github.com/phpstan/phpstan-phpunit)). `/php-lint-setup` suggests it.

If the repository does not keep `phpunit.xml` at the root, pass `--configuration`. The Cadasto template-repo runs `vendor/bin/phpunit --configuration tests/phpunit.xml --no-coverage --display-deprecations --display-notices --display-warnings`. Use the flags the repository already uses. This file covers PHPUnit 12 ([manual](https://docs.phpunit.de/en/12.5/)). Do not add Pest.

## Scope

A request for tests is not a request to change the code under test. If a test exposes a bug, report it. Do not delete, skip, or loosen a failing test to get a green run. Run every new test once before calling it done.

## Rules

- **Metadata lives in attributes only.** PHPUnit 12.0 removed support for metadata in doc-comments ([12.0.0 release notes](https://github.com/sebastianbergmann/phpunit/releases/tag/12.0.0), #5541), so `@dataProvider`, `@covers`, `@depends`, `@group`, and `@test` are ignored. Use `#[DataProvider]`, `#[CoversClass]`, and the other attributes ([attributes](https://docs.phpunit.de/en/12.5/attributes.html)), even when neighbouring tests still carry annotations. Those tests are the ones to migrate.
- **Table-driven cases are a data provider.** One test method, many named cases, via `#[DataProvider]`, `#[TestWith]`, or `#[TestWithJson]` ([writing tests](https://docs.phpunit.de/en/12.5/writing-tests-for-phpunit.html)). The array key or `TestDox` text names the case, so a failure says which row broke. Do not copy the same arrange-act-assert block once per input.
- **Identity, not equality, when the type is part of the result.** PHPUnit lists `assertSame()` under Identity and `assertEquals()` under Equality ([assertions](https://docs.phpunit.de/en/12.5/assertions.html)). `assertEquals()` accepts a coerced value. Use `assertSame()` for scalars, lists, and shapes; floats with a tolerance use `assertEqualsWithDelta()`.
- **Expect an exception before the act, never with `try`/`catch`.** The manual's structure is "Arrange, Expect, Act": `expectException()` goes before the call ([writing tests](https://docs.phpunit.de/en/12.5/writing-tests-for-phpunit.html)). A `try`/`catch` around the act passes when nothing is thrown, unless every path ends in `fail()`.
- **A guard gets a test that fails when the guard is removed.** Call the guarded path with the rejected input and expect the specific exception type. Deleting the `if` or the `throw` must turn that test red. A check you ran by hand and reverted is not that test.
- **Declare what a test covers.** Use `#[CoversClass]`, `#[CoversMethod]`, or `#[CoversFunction]` for the unit under test, and `#[UsesClass]` for collaborators it is allowed to execute ([attributes](https://docs.phpunit.de/en/12.5/attributes.html)). In `phpunit.xml`, `requireCoverageMetadata="true"` marks a test without a target as risky, `beStrictAboutCoverageMetadata="true"` marks one that runs code it did not declare, and `failOnRisky="true"` turns risky into a failure ([XML configuration](https://docs.phpunit.de/en/12.5/configuration.html), [risky tests](https://docs.phpunit.de/en/12.5/risky-tests.html)).
- **Share a fixture only when it is expensive and no test changes it.** The manual: "There are few good reasons to share fixtures between tests, but in most cases the need to share a fixture between tests stems from an unresolved design problem." A database connection is its example of a good one ([fixtures](https://docs.phpunit.de/en/12.5/fixtures.html)). Otherwise build it in `setUp()`, not `setUpBeforeClass()`.
- **Control time and I/O at the seam.** Inject a PSR-20 clock rather than calling `new DateTimeImmutable()` inside the unit (see `psr.md`). Mock HTTP with Guzzle's `MockHandler` rather than the network (see `guzzle.md`).
- **Match the assertion style the repository already has.** Do not add a second assertion library to a test that only needed `assertSame`.

## Sources

- PHPUnit 12.5 manual: writing tests, assertions, attributes, fixtures, XML configuration, risky tests — linked inline above
- PHPUnit 12.0.0 release notes — <https://github.com/sebastianbergmann/phpunit/releases/tag/12.0.0>
- phpstan-phpunit README (2.0.19 on 2026-09-30) — <https://github.com/phpstan/phpstan-phpunit>
