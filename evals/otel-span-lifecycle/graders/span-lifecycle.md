---
type: llm
weight: 2
---

PASS if the code activates the span and, in a `finally` block, both detaches the scope and ends the span, AND on an exception records it, sets an error status, and rethrows it, AND the span name does not contain the order id (the id may go in an attribute).
FAIL if `end()` or `detach()` can be skipped on the exception path, if the exception is swallowed, or if the order id is part of the span name.
