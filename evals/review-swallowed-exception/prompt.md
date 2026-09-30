---
description: A review request on code with an empty catch and a loose comparison. The idioms reference should drive the findings.
max_turns: 12
allowed_tools: [Read, Glob, Grep, Skill]
---

Can you review this PHP method before I merge it? It's from our billing service.

```php
<?php

declare(strict_types=1);

final class InvoiceWriter
{
    public function __construct(private \PDO $db) {}

    public function markPaid(string $invoiceId, string $status): void
    {
        if ($status == 0) {
            return;
        }

        try {
            $stmt = $this->db->prepare('UPDATE invoices SET paid = 1 WHERE id = ?');
            $stmt->execute([$invoiceId]);
        } catch (\Throwable $e) {
        }
    }
}
```
