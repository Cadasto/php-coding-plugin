<?php

declare(strict_types=1);

/**
 * Reference php-cs-fixer config. php-lint-setup copies this to the repo root as
 * `.php-cs-fixer.php`. Keep the two in sync.
 *
 * `@PER-CS` is the alias for the newest PER ruleset the fixer ships. Checked
 * 2026-09-30 against the docs and against php-cs-fixer 3.95.27
 * (`describe @PER-CS` prints `@PER-CS3x0`, PER Coding Style 3.0).
 * `@PER-CS3.0` is deprecated. https://cs.symfony.com/doc/ruleSets/PER-CS.html
 * PER Coding Style 3.1 (tagged 2026-08-13) is the current standard; the fixer
 * has no 3.1 set yet. https://github.com/php-fig/per-coding-style/blob/3.1.0/migration-3.1.md
 *
 * `declare_strict_types` is NOT part of `@PER-CS`. PER shows the declare in
 * examples and does not require it. The Cadasto template-repo does
 * (`.cursor/rules/php-standards.mdc`). The rule is marked risky, so
 * `setRiskyAllowed(true)` is required; no other risky rule is enabled.
 *
 * php-cs-fixer has no language-version key. The pin is PHP 8.4, set in
 * `references/phpstan.neon` (`phpVersion: 80400`).
 */

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
