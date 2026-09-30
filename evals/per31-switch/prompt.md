---
description: PER 3.1 switch rules that php-cs-fixer @PER-CS does not apply yet.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Please bring this PHP 8.4 snippet in line with our coding standard and show me the corrected code.

```php
<?php

declare(strict_types=1);

function label(int $code): string
{
    switch ($code) {
        case 1: {
            $label = 'new';
            break;
        }
        case 2:
            $label = 'paid';
            break;
        default:
            $label = 'unknown';
    }

    return $label;
}
```
