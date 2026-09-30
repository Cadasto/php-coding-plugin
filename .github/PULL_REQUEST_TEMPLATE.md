## Summary

<!-- What changed, and which reference, tool, or source it follows. -->

## Test plan

- [ ] `./scripts/validate.sh` (checks index links, the Cursor rule mirror, and reference names)
- [ ] `claude plugin validate .` shows no warnings
- [ ] No reference restates a rule `@PER-CS`, PHPStan level 8, or `composer audit` already enforces
- [ ] Every new rule cites a primary source
- [ ] A new or changed reference has an eval case under `evals/`
