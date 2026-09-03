#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

fail=0
warn=0
pass(){ printf 'PASS  %s\n' "$1"; }
warning(){ printf 'WARN  %s\n' "$1"; warn=1; }
failure(){ printf 'FAIL  %s\n' "$1" >&2; fail=1; }

printf '=== PUBLIC PROJECTION AUDIT v2 ===\n'

for p in README.md docs media release; do
  [[ -e "$p" ]] && pass "present: $p" || failure "missing: $p"
done

if [[ -x release/v1.0.0/verify_artifact.sh ]] &&
   (cd release/v1.0.0 && ./verify_artifact.sh >/dev/null); then
  pass "frozen release verifier"
else
  failure "frozen release verifier"
fi

if (cd release/v1.0.0 && sha256sum -c MANIFEST.sha256 >/dev/null 2>&1); then
  pass "frozen release MANIFEST.sha256"
else
  failure "frozen release MANIFEST.sha256"
fi

sidecar="release/artifact_001-v1.0.0.tar.gz.sha256"
expected='39002686a9409d0160de8511075889656af0721d81c4e8b924cfb5a233771576  artifact_001-v1.0.0.tar.gz'
[[ "$(cat "$sidecar" 2>/dev/null || true)" == "$expected" ]] \
  && pass "archive checksum sidecar is relative and canonical" \
  || failure "archive checksum sidecar is not canonical/relocatable"

if (cd release && sha256sum -c artifact_001-v1.0.0.tar.gz.sha256 >/dev/null 2>&1); then
  pass "release archive checksum"
else
  failure "release archive checksum"
fi

hits="$(grep -RInaE --binary-files=without-match \
  --exclude='verify_artifact.sh' --exclude='RELEASE_CHECKLIST.md' \
  '(/home/[^/]+/|/Users/[^/]+/|[A-Za-z]:\\Users\\)' \
  README.md docs release 2>/dev/null | head -n 20 || true)"

if [[ -n "$hits" ]]; then
  warning "machine-specific path-like text found:"
  printf '%s\n' "$hits"
else
  pass "no unintended machine-specific absolute paths"
fi

secret_regex='(BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|api[_-]?key[[:space:]]*[:=]|password[[:space:]]*[:=]|secret[[:space:]]*[:=]|access[_-]?token[[:space:]]*[:=])'
secret_hits="$(grep -RInaE --binary-files=without-match "$secret_regex" README.md docs release 2>/dev/null | head -n 20 || true)"
[[ -z "$secret_hits" ]] && pass "no obvious credential/secret patterns" || { warning "possible secret-like text found:"; printf '%s\n' "$secret_hits"; }

debris="$(find . -type f \( -name '*.bak' -o -name '*~' -o -name '*.tmp' -o -name '*.swp' -o -name '*.pyc' -o -name '.DS_Store' -o -name 'Thumbs.db' -o -name '*.log' \) -print | head -n 20)"
[[ -z "$debris" ]] && pass "no obvious workspace debris" || { warning "workspace debris found:"; printf '%s\n' "$debris"; }

printf '\n=== AUDIT RESULT ===\n'
if (( fail )); then
  echo 'PUBLIC PROJECTION AUDIT: FAIL'
  exit 1
elif (( warn )); then
  echo 'PUBLIC PROJECTION AUDIT: PASS WITH WARNINGS'
else
  echo 'PUBLIC PROJECTION AUDIT: PASS'
fi
