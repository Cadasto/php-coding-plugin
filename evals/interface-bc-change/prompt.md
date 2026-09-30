---
description: Adding a method to an interface that a published library ships. The compatibility reference should flag the break and offer a non-breaking path.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

We maintain `acme/payments` (currently 2.3.0 on our Packagist), and three other teams implement its gateway interface for their providers. Please add refund support by adding this method to the interface:

```php
interface PaymentGatewayInterface
{
    public function charge(string $orderId, Money $amount): Receipt;
}
```

The new method should be `refund(string $receiptId, Money $amount): Refund`. Show me the change.
