---
type: llm
weight: 2
---

PASS if the suggested call passes `$orderId` through the context array instead of concatenating it into the message, AND passes the exception object itself under the `exception` context key, AND, if the message uses a `{placeholder}`, says that Monolog needs `PsrLogMessageProcessor` to fill it in.
FAIL if the reply keeps the concatenated message, passes only `$e->getMessage()` without the exception object, or claims Monolog replaces `{placeholders}` on its own.
