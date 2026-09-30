---
description: Loose in_array() and an unchecked json_decode(). The idioms reference should lead to strict search and JSON_THROW_ON_ERROR.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

PHPStan level 8 is green on this, but QA says some invalid webhooks get through. Can you review it?

```php
public function accept(string $body): bool
{
    $payload = json_decode($body, true);
    $allowed = ['order.paid', 'order.refunded'];

    return in_array($payload['event'] ?? null, $allowed);
}
```
