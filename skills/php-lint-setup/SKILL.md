---
name: php-lint-setup
description: Scaffold the reference PHP lint config into a repository. This skill should be used when the user runs /php-lint-setup or asks to set up, scaffold, or bootstrap php-cs-fixer, PHPStan, or the PHP 8.4 pin. It writes @PER-CS plus declare_strict_types, and PHPStan level 8 with phpVersion 80400. Rector is optional and stays off unless asked. Not for explaining a rule (read the php-coding references) or for non-PHP projects.
argument-hint: optional target directory (defaults to the repository root)
allowed-tools: Read, Write, Glob
---

# php-lint-setup — reference PHP config

Write the plugin's reference config so the repo's tools match the skills. Single interaction. The pin is **PHP 8.4**. Do not write a PHPCS PSR-12 ruleset. `@PER-CS` already includes `@PSR12`, and PER replaces PSR-12 as the living standard.

`$ARGUMENTS` is an optional directory. Default is the repository root. Call that directory `$ROOT` below.

## Steps

1. **Do not overwrite an existing config.** If `$ROOT/.php-cs-fixer.php`, `$ROOT/.php-cs-fixer.dist.php`, `$ROOT/phpstan.neon`, or `$ROOT/phpstan.neon.dist` exists, show how it differs and ask before changing it.
2. **Write** `$ROOT/.php-cs-fixer.php` and `$ROOT/phpstan.neon` from the blocks below. If `src/` or `tests/` is missing, drop that path rather than inventing it. If `composer.json` has a `php` constraint higher than `^8.4`, keep it and set `phpVersion` to that minor (`80500` for 8.5). Do not lower a constraint.
3. **Rector stays off.** Write `$ROOT/rector.php` only when the user asked for Rector. It is not part of the default check.
4. **Report the commands:** `vendor/bin/php-cs-fixer fix --dry-run --diff`, `vendor/bin/phpstan analyse`, `vendor/bin/phpunit`, and `composer dump-autoload --optimize --strict-psr`. Suggest Composer dev requirements `friendsofphp/php-cs-fixer`, `phpstan/phpstan` `^2`, `phpunit/phpunit` `^12.5`, and `phpstan/phpstan-phpunit` with `phpstan/extension-installer` (which loads the extension without editing `phpstan.neon`), and `"php": "^8.4"` when `composer.json` has no PHP constraint yet. For a package other code depends on, also suggest `roave/backward-compatibility-check` (see the php-coding `compatibility.md` reference).

After Rector, if it was asked for, run php-cs-fixer again. Rector's PHP 8.4 set can strip `new` parentheses that `@PER-CS` puts back. The fixer wins. Do not enable Rector prepared sets (`deadCode`, `codeQuality`, `codingStyle`) in the file you write; the template-repo turned the first two on, and a coding-style set can disagree with `@PER-CS`.

## `.php-cs-fixer.php`

Mirrors `references/php-cs-fixer.php`. `@PER-CS` aliases the newest set the fixer ships, `@PER-CS3x0` (PER 3.0). PER 3.1 is the current standard; its additions are listed in the php-coding `style.md` reference and are followed by hand until the fixer ships a 3.1 set. `declare_strict_types` is outside PER; `setRiskyAllowed(true)` is only there so that one risky rule runs.

```php
<?php

declare(strict_types=1);

use PhpCsFixer\Config;
use PhpCsFixer\Finder;

$finder = (new Finder())
    ->in(__DIR__)
    ->exclude(['vendor', 'var']);

return (new Config())
    ->setRules([
        '@PER-CS' => true,
        'declare_strict_types' => true,
    ])
    ->setRiskyAllowed(true)
    ->setFinder($finder);
```

php-cs-fixer has no language-version key. The pin lives in `phpstan.neon`.

## `phpstan.neon`

Mirrors `references/phpstan.neon`. Level 8 is the template-repo level. `80400` is PHP 8.4 (<https://phpstan.org/config-reference>). Leave `treatPhpDocTypesAsCertain` unset (default `true`); the template-repo sets `false`, which relaxes checks.

```neon
parameters:
    level: 8
    phpVersion: 80400
    paths:
        - src
        - tests
```

## `rector.php` (only if asked)

Mirrors `references/rector.php`. <https://getrector.com/documentation/set-lists>

```php
<?php

declare(strict_types=1);

use Rector\Config\RectorConfig;
use Rector\ValueObject\PhpVersion;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/src',
        __DIR__ . '/tests',
    ])
    ->withPhpSets(php84: true)
    ->withPhpVersion(PhpVersion::PHP_84);
```
