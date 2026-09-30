---
type: llm
weight: 2
---

PASS if the function builds the `Process` from an array of arguments (for example `['git', 'log', '--oneline', $ref . '..HEAD']`) rather than a shell string with `$ref` interpolated, AND makes a git failure visible by calling `mustRun()` or by checking `isSuccessful()` and throwing.
FAIL if `$ref` is interpolated into a string passed to `Process::fromShellCommandline()`, `exec()`, or `shell_exec()`, or if the function calls `run()` and returns the output without checking the result.
