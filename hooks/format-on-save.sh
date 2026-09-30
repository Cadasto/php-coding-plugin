#!/usr/bin/env bash
# PostToolUse / afterFileEdit hook (host-agnostic): format the just-edited PHP file.
#
# Runs `php-cs-fixer fix` on that single file when a project config is present
# (`.php-cs-fixer.php` or `.php-cs-fixer.dist.php`) and a fixer binary is available.
# Prefers `vendor/bin/php-cs-fixer`, then `php-cs-fixer` on PATH. Host-only by design.
# Silent no-op when the fixer or the config is missing, and ALWAYS exits 0 so it can
# never block an edit. The fixer owns style; this hook does not pass a second ruleset.
#
# File-path resolution, in order:
#   1. $CLAUDE_FILE_PATH          — set by Claude Code for Write/Edit hooks (fast path).
#   2. tool payload JSON on stdin — Claude (`tool_input.file_path`) or Cursor
#      `afterFileEdit` (`file_path`). Extracted without a jq/python dependency.
set -u

f="${CLAUDE_FILE_PATH:-}"

# Fall back to the JSON the host pipes in on stdin (Cursor; newer Claude payloads).
# Guard on a non-tty stdin so a manual run without a pipe doesn't block on `cat`.
if [ -z "$f" ] && [ ! -t 0 ]; then
  payload="$(cat)"
  f="$(printf '%s' "$payload" \
        | grep -oE '"file_?[Pp]ath"[[:space:]]*:[[:space:]]*"[^"]+"' \
        | head -n1 \
        | sed -E 's/.*"([^"]+)"$/\1/')"
fi

[ -n "$f" ] || exit 0
case "$f" in *.php) ;; *) exit 0 ;; esac
[ -f "$f" ] || exit 0

root="$(pwd)"
config=""
if [ -f "$root/.php-cs-fixer.php" ]; then
  config="$root/.php-cs-fixer.php"
elif [ -f "$root/.php-cs-fixer.dist.php" ]; then
  config="$root/.php-cs-fixer.dist.php"
fi
[ -n "$config" ] || exit 0

fixer=""
if [ -x "$root/vendor/bin/php-cs-fixer" ]; then
  fixer="$root/vendor/bin/php-cs-fixer"
elif command -v php-cs-fixer >/dev/null 2>&1; then
  fixer="php-cs-fixer"
fi
[ -n "$fixer" ] || exit 0

"$fixer" fix "$f" --config="$config" >/dev/null 2>&1 || true

exit 0
