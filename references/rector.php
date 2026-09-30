<?php

declare(strict_types=1);

/**
 * Optional, default-off. Not part of the default check.
 *
 * Pin: PHP 8.4 (`withPhpSets(php84: true)` plus `PhpVersion::PHP_84`), the same
 * floor as `references/phpstan.neon`. Docs:
 * https://getrector.com/documentation/set-lists
 *
 * Prepared sets (deadCode, codeQuality, codingStyle) are not enabled. A
 * coding-style set can disagree with php-cs-fixer `@PER-CS`, and the PHP 8.4
 * set can strip parentheses that `new_with_parentheses` puts back. After Rector
 * runs, run php-cs-fixer. The fixer wins on style.
 */

use Rector\Config\RectorConfig;
use Rector\ValueObject\PhpVersion;

return RectorConfig::configure()
    ->withPaths([
        __DIR__ . '/src',
        __DIR__ . '/tests',
    ])
    ->withPhpSets(php84: true)
    ->withPhpVersion(PhpVersion::PHP_84);
