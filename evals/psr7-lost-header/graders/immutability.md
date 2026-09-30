---
type: llm
weight: 2
---

PASS if the reply explains that PSR-7 messages are immutable so `withHeader()` and `withAttribute()` return new instances that are being discarded, AND the fix assigns or returns both results (the new request is passed to `$handler->handle()`, and the new response is returned).
FAIL if it fixes only the header and still passes the original request without the attribute, or blames something other than the discarded return values.
