---
type: llm
weight: 2
---

PASS if the corrected code removes the braces around the body of `case 1`, AND ends the `default` branch with a terminating statement such as `break` (or rewrites the whole switch as a `match` expression, which avoids both problems).
FAIL if the braces remain around a case body, or if the last branch still has no terminating statement and the switch is kept.
