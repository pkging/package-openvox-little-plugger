#!/usr/bin/env bash
set -euo pipefail

PKG_NAME="openvox-agent-little-plugger"
GEM_BIN="/opt/puppetlabs/puppet/bin/gem"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

if command -v rpm >/dev/null 2>&1; then
  rpm -q "$PKG_NAME" >/dev/null 2>&1 || fail "RPM package $PKG_NAME is not installed"
elif command -v dpkg-query >/dev/null 2>&1; then
  dpkg-query -W -f='${Status}\n' "$PKG_NAME" 2>/dev/null | grep -q '^install ok installed$' \
    || fail "DEB package $PKG_NAME is not installed"
else
  fail "Neither rpm nor dpkg-query is available"
fi

[ -x "$GEM_BIN" ] || fail "$GEM_BIN is missing or not executable"

"$GEM_BIN" list '^little-plugger$' -i >/dev/null 2>&1 || fail "Ruby gem 'little-plugger' is not installed"

"$GEM_BIN" info little-plugger >/dev/null 2>&1 || fail "Ruby gem 'little-plugger' is not queryable"

echo "Smoke test passed: package and little-plugger gem are installed"
