# Style — what the fixer does not settle

Read when: a diff raises naming, line length, one type per file, a namespace that must match its path, side effects in a file that declares symbols, or a `switch`, closure, `clone`, enum constant, or anonymous class that PER 3.1 formats differently.

Deterministic backstop: `vendor/bin/php-cs-fixer fix --dry-run --diff` with `@PER-CS`.

The standard is [PER Coding Style 3.1](https://www.php-fig.org/per/coding-style/). It extends and replaces PSR-12, which stays the frozen baseline PER still accepts. Do not add a PHPCS PSR-12 ruleset beside the fixer.

The fixer owns braces, indentation, keyword and cast case, spacing, trailing commas, import grouping, compound-type layout, and `null` last in a union. Do not restate those. Do not configure a hard line wrap, an alphabetical import sort, a member-order list, or Yoda conditions. PER does not decide them, and a second guide would fight the fixer.

## Rules the fixer leaves green

- **Lines.** PER section 2.3: there MUST NOT be a hard limit; the soft limit MUST be 120 characters; lines SHOULD NOT exceed 80. `line_length` is not part of `@PER-CS`. Split a line past 120, and prefer splitting past 80. Do not add a rule that turns either number into an error.
- **Acronyms are words.** PER section 2.7: avoid abbreviations unless the short form is much more widely used, and write them with an uppercase first letter and the rest lower (`Xml`, `Http`). The fixer does not rename symbols.
- **PSR-1, required by PER section 2.1.** The fixer does not include `psr_autoloading`.
  - A file SHOULD declare symbols or cause side effects, and SHOULD NOT do both (PSR-1 section 2.3). Output, `include`, ini changes, and I/O at file scope are side effects.
  - Each class is in a file by itself, in a namespace of at least one level (PSR-1 section 3). Class names are PascalCase.
  - Class constants are `UPPER_SNAKE` (PSR-1 section 4.1). Method names are `camelCase` (PSR-1 section 4.3). PSR-1 makes no recommendation on property names; do not add one.
- **The file path follows the PSR-4 map in `composer.json`.** A class whose namespace and path disagree with the `autoload` map still type-checks. `composer dump-autoload --optimize --strict-psr` exits non-zero on a PSR-4 or PSR-0 mapping error in the project ([Composer CLI](https://getcomposer.org/doc/03-cli.md#dump-autoload-dumpautoload-)); run it instead of checking paths by hand.

## PER 3.1 additions

The fixer's newest set is `@PER-CS3x0`, which implements PER 3.0. The PER 3.1 migration document exists "to drive action lists for toolset producers to support PER-CS v3.1". Follow these by hand until the fixer ships a 3.1 set.

- **`clone($a)`** SHOULD always take parentheses, with or without the second argument (section 4.7).
- **`switch`** (section 5.2): a `case` body MUST NOT be wrapped in `{}`. Every non-empty `case` MUST end with `break`, `return`, or another terminating statement, including the last one. A multi-line `case` condition MUST be wrapped in parentheses, with `):` alone on the final line.
- **Empty closures** (section 7): the body is `{}` on the same line, and SHOULD become an arrow function where possible (`fn() => null`).
- **Anonymous class attributes** (section 8) start on the line after `new`, indented once, and the `class` keyword follows on its own line.
- **Non-public enum constants** MUST be `private`, not `protected` (section 9), as enum methods already had to be.
- **A multi-line array's opening bracket** MUST NOT sit on its own line, in any context, including a call argument (section 11).
- **The pipe operator `|>`** (PHP 8.5 only) takes a space on each side and leads each line of a split chain (sections 6.2 and 6.4).

## Sources

- PER Coding Style 3.1, sections 2.1, 2.3, 2.7, 4.7, 5.2, 6.2, 6.4, 7, 8, 9, 11 — <https://www.php-fig.org/per/coding-style/>, <https://github.com/php-fig/per-coding-style/blob/3.1.0/spec.md>
- PER 3.0 to 3.1 migration — <https://github.com/php-fig/per-coding-style/blob/3.1.0/migration-3.1.md>
- PSR-1 — <https://www.php-fig.org/psr/psr-1/>
- Composer `dump-autoload --strict-psr` — <https://getcomposer.org/doc/03-cli.md#dump-autoload-dumpautoload->
- `@PER-CS` and `@PER-CS3x0` rule lists — <https://cs.symfony.com/doc/ruleSets/PER-CS.html>, <https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/blob/master/doc/ruleSets/PER-CS3x0.rst>
