---
description: A string-built log line in a Monolog 3 app. The Monolog reference should lead to context, the exception key, and the placeholder processor.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

We use Monolog 3 behind `Psr\Log\LoggerInterface`. Is this log call fine, and if not, what should it be?

```php
} catch (PaymentFailed $e) {
    $this->logger->error('Charge failed for order ' . $orderId . ': ' . $e->getMessage());
    throw $e;
}
```
