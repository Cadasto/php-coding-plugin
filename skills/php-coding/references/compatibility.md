# Compatibility — changing a public API

Read when: a diff changes a public or protected class, interface, method signature, parameter name, property, or constant in a package that other code depends on, or prepares a release.

Deterministic backstop: `vendor/bin/roave-backward-compatibility-check` (`composer require --dev roave/backward-compatibility-check`). It compares the API of the last minor tag with `HEAD` and exits non-zero on a break. It needs SemVer `x.y.z` tags and, in CI, a checkout with the full history ([README](https://github.com/Roave/BackwardCompatibilityCheck)). PHPStan level 8 checks that callers match the new signature, not that existing callers and subclasses still work.

The table-level rules below come from Symfony's backward compatibility promise, the most detailed published list for PHP ([BC promise](https://symfony.com/doc/current/contributing/code/bc.html)).

## Rules

- **A break in the public API needs a new major version.** SemVer item 8: the major version MUST be incremented for any backward incompatible change to the public API. Under `0.y.z` anything may change (item 4) ([SemVer 2.0.0](https://semver.org/spec/v2.0.0.html)).
- **An interface is frozen.** Adding a method breaks every implementer. So does adding an argument (with or without a default), removing one, or adding, removing, or changing a parameter or return type ([BC promise](https://symfony.com/doc/current/contributing/code/bc.html), "Changing Interfaces"). Ship a new interface instead.
- **A non-final class is nearly frozen.** Adding a public method is allowed. Removing a public or protected method, adding an argument even with a default, removing one, changing a parameter or return type, or making the class or a method `final` breaks code that extends or calls it. Most of these become allowed once the class or method is already final ([BC promise](https://symfony.com/doc/current/contributing/code/bc.html), "Changing Classes").
- **Removing a public property breaks callers; removing a protected one breaks subclasses** ([BC promise](https://symfony.com/doc/current/contributing/code/bc.html)).
- **Parameter names are part of the call surface since PHP 8.0.** Named arguments pass values "based on the parameter name, rather than the parameter position" ([arguments](https://www.php.net/manual/en/functions.arguments.php)), so renaming a parameter breaks a caller that names it. Symfony covers parameter names only for Attribute class constructors and warns that named arguments "might break your code when upgrading" (note 10). Treat a rename as breaking unless the package documents the same exclusion.
- **Deprecate, then remove in the next major.** Keep the old API working and deprecate it instead of removing it ([BC promise](https://symfony.com/doc/current/contributing/code/bc.html), quick reference). On the 8.4 pin, `#[\Deprecated]` makes the engine warn callers (see `idioms.md`).
- **Say what is not API.** Symfony excludes code tagged `@internal` from its promise. To close a class later, Symfony first adds `@final` so extenders get a warning, then switches to the native `final` keyword in the next major ([BC promise](https://symfony.com/doc/current/contributing/code/bc.html), note 6). Make a new class `final` from the start unless it is meant for extension.

## Sources

- Roave BackwardCompatibilityCheck README (8.22.0 on 2026-09-30) — <https://github.com/Roave/BackwardCompatibilityCheck>
- Semantic Versioning 2.0.0, items 4 and 8 — <https://semver.org/spec/v2.0.0.html>
- PHP manual, named arguments — <https://www.php.net/manual/en/functions.arguments.php>
- Symfony backward compatibility promise — <https://symfony.com/doc/current/contributing/code/bc.html>
