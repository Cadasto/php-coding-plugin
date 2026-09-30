#!/usr/bin/env bash
# SessionStart hook (host-agnostic): print one PHP-standards context line when a PHP
# workspace is detected, naming the php-coding references that match composer.json.
# Always exits 0 so the assistant reads stdout and is never blocked.
set -u

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
  line="› PHP workspace detected: php-coding standards apply (PHP 8.4 pin, PER Coding Style 3.1, php-cs-fixer @PER-CS, PHPStan level 8). Load the php-coding skill and read the reference each change maps to."
  refs="$(library_refs)"
  [ -n "$refs" ] && line="$line composer.json also maps to: $refs."
  if [ -f composer.json ] && grep -q '"laravel/framework"' composer.json; then
    line="$line Laravel framework code belongs to Laravel Boost."
  fi
  echo "$line"
fi

exit 0
