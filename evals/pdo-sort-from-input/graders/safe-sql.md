---
type: llm
weight: 2
---

PASS if the function binds `$customerId` through a placeholder passed to `execute()` or `bindValue()`, AND maps `$sort` and `$direction` through a fixed allowlist (an array lookup, `match`, or `in_array` with a default or a rejection) so the raw input string never reaches the SQL text.
FAIL if `$sort` or `$direction` is interpolated or concatenated into the SQL without such a mapping, if it tries to bind the column name as a parameter, or if it relies on `PDO::quote()` or escaping for the identifier.
