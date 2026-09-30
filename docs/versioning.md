# Versioning and Releases

This plugin uses [Semantic Versioning](https://semver.org), adapted to skill and agent content:

| Bump | When |
|------|------|
| **Major** | A skill, reference, or agent is removed or renamed, or its scope changes incompatibly |
| **Minor** | A new component or reference is added, or coverage meaningfully expands |
| **Patch** | Typos, clarifications, source-link fixes — no behaviour change |

While on the `0.x` line, a breaking change may still ship in a minor bump.

## Release steps

1. Bump `version` in **both** manifests. Keep `description` and `author` identical — `scripts/validate.py` checks this.
2. Run `./scripts/validate.sh` and `claude plugin validate .`.
3. Dogfood against a real PHP change on both hosts — see [testing.md](testing.md).
4. Fold `## [Unreleased]` into a dated `## [X.Y.Z] - YYYY-MM-DD` section in [CHANGELOG.md](../CHANGELOG.md).
5. Sync AGENTS.md and README.md with what shipped, including the session-start line if it lists components. If a dated version fact changed, update every copy (AGENTS.md, *Refreshing a dated fact*).
6. Commit (`chore(release): vX.Y.Z`) and tag `vX.Y.Z`.

## No MCP

This plugin has no companion MCP server. It is intended for the Cadasto marketplace (`php-coding@cadasto`). The marketplace tracks the default branch; update that entry when `name`, `description`, or `repository` changes.
