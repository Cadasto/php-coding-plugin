---
description: Wrapping a function in an OpenTelemetry span. The OpenTelemetry reference should lead to end and detach in finally, and an error status on failure.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

We have OpenTelemetry set up in our PHP 8.4 app (the SDK autoloads from env). Add a span around this method so we can see card charges in our traces, including failures:

```php
public function charge(string $orderId, Money $amount): Receipt
{
    return $this->gateway->charge($orderId, $amount);
}
```
