#!/usr/bin/env bash
# SessionStart (Claude Code) / sessionStart (Cursor) hook: print one PHP-standards context
# line when a PHP workspace is detected, naming the php-coding references that match
# composer.json. Always exits 0.
#
# Claude Code runs the hook in its current directory and reads plain stdout.
# Cursor runs a plugin hook from the plugin install and reads additional_context
# from JSON, so there the hook moves to CURSOR_PROJECT_DIR
# (https://cursor.com/docs/agent/hooks).
set -u

# CURSOR_PLUGIN_ROOT is set only for a Cursor plugin hook. Without CURSOR_PROJECT_DIR the hook
# stays silent: the plugin install ships references/*.php and would read as a PHP workspace.
cursor=""
if [ -n "${CURSOR_PLUGIN_ROOT:-}" ]; then
  cursor=1
  [ -n "${CURSOR_PROJECT_DIR:-}" ] && cd "$CURSOR_PROJECT_DIR" 2>/dev/null || exit 0
fi

is_php_workspace() {
  [ -f composer.json ] && return 0
  # Bounded search so session start stays fast; ignore vendor/ and .git/.
  if find . -maxdepth 4 -name '*.php' -not -path './vendor/*' -not -path './.git/*' 2>/dev/null \
      | grep -q .; then
    return 0
  fi
  return 1
}

# Library references that apply, from package names in composer.json. A plain grep keeps the
# hook free of jq and php; a package listed only under "suggest" or "conflict" also matches.
library_refs() {
  [ -f composer.json ] || return 0
  local refs=""
  grep -qE '"psr/[a-z-]+"' composer.json && refs="$refs psr.md"
  grep -q '"guzzlehttp/guzzle"' composer.json && refs="$refs guzzle.md"
  grep -q '"monolog/monolog"' composer.json && refs="$refs monolog.md"
  grep -q '"open-telemetry/' composer.json && refs="$refs opentelemetry.md"
  grep -q '"slim/slim"' composer.json && refs="$refs slim.md"
  grep -oE '"symfony/[a-z0-9-]+"' composer.json 2>/dev/null | grep -qv '"symfony/polyfill' \
    && refs="$refs symfony-components.md"
  printf '%s' "${refs# }"
}

if is_php_workspace; then
  if [ -n "$cursor" ]; then
    line="› PHP workspace detected: php-coding standards apply (PHP 8.4 pin, PER Coding Style 3.1, php-cs-fixer @PER-CS, PHPStan level 8). Open /php-coding and read the reference each change maps to."
  else
    line="› PHP workspace detected: php-coding standards apply (PHP 8.4 pin, PER Coding Style 3.1, php-cs-fixer @PER-CS, PHPStan level 8). Load the php-coding skill and read the reference each change maps to."
  fi
  refs="$(library_refs)"
  [ -n "$refs" ] && line="$line composer.json also maps to: $refs."
  if [ -f composer.json ] && grep -q '"laravel/framework"' composer.json; then
    line="$line Laravel framework code belongs to Laravel Boost."
  fi
  if [ -n "$cursor" ]; then
    # One JSON string: escape backslashes and double quotes.
    printf '{"additional_context":"%s"}\n' "$(printf '%s' "$line" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  else
    echo "$line"
  fi
fi

exit 0
