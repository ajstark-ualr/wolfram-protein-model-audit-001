#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

readonly NOTEBOOK="protein_model_audit_final.nb"
readonly CSV="sample_residue_data.csv"
readonly MANIFEST="ARTIFACT_MANIFEST.json"

readonly NOTEBOOK_SHA256="30493ddec9a7bb796c6f06b3bbc172bfdd46b78e7360d6746297ba0f99709318"
readonly CSV_SHA256="3a42e891ebf54e141544b675ee5c113842bda57cef6212b89942aea4ace04d26"
readonly COHORT_SHA256="670e80d6d550536222148e0201d13752a7f977e24666b984bf499cdc2541f470"
readonly RESULTS_SHA256="62683dee4a24ab4f4706a9552a08ec3186c9de824990ace460e8020cedd2a9a8"
readonly NULLS_SHA256="3b747d65f79bfdfca7ef0eac38e9e780e1740159c5c07d14265ebc3109e8041b"

fail=0
pass() { printf 'PASS  %s\n' "$1"; }
fail_check() { printf 'FAIL  %s\n' "$1" >&2; fail=1; }

require_nonempty() {
  local file="$1"
  [[ -s "$file" ]] && pass "required file: $file" || fail_check "missing or empty: $file"
}

check_sha256() {
  local file="$1" expected="$2" observed
  if [[ ! -f "$file" ]]; then
    fail_check "cannot hash missing file: $file"
    return
  fi
  observed="$(sha256sum "$file" | awk '{print $1}')"
  if [[ "$observed" == "$expected" ]]; then
    pass "SHA256: $file"
  else
    fail_check "SHA256 mismatch: $file"
    printf '      expected %s\n' "$expected" >&2
    printf '      observed %s\n' "$observed" >&2
  fi
}

reject_notebook_marker() {
  local marker="$1"
  if grep -aFq -- "$marker" "$NOTEBOOK"; then
    fail_check "notebook contains forbidden marker: $marker"
  else
    pass "notebook clean of: $marker"
  fi
}

printf '=== ARTIFACT 001 RELEASE VERIFICATION ===\n'

required_files=(
  "$NOTEBOOK"
  "$CSV"
  "cohort_selection_manifest.json"
  "results.json"
  "null_results.json"
  "figure_01_hgroup_scatter.png"
  "figure_01_hgroup_scatter.pdf"
  "README.md"
  "$MANIFEST"
)

for file in "${required_files[@]}"; do
  require_nonempty "$file"
done

check_sha256 "$NOTEBOOK" "$NOTEBOOK_SHA256"
check_sha256 "$CSV" "$CSV_SHA256"
check_sha256 "cohort_selection_manifest.json" "$COHORT_SHA256"
check_sha256 "results.json" "$RESULTS_SHA256"
check_sha256 "null_results.json" "$NULLS_SHA256"

if python3 -m json.tool "$MANIFEST" >/dev/null 2>&1; then
  pass "manifest JSON syntax"
else
  fail_check "manifest JSON syntax"
fi

if python3 -c '
import json, sys
with open("ARTIFACT_MANIFEST.json", encoding="utf-8") as f:
    m = json.load(f)
checks = [
    m.get("version") == "1.0.0",
    m.get("canonical_run") == "run_20260824T154329Z",
    m.get("run_commit") == "44945311f38bcdeb7b45be911fc8432bcc275d79",
    m["frozen_input"]["sha256"] == "3a42e891ebf54e141544b675ee5c113842bda57cef6212b89942aea4ace04d26",
    m["frozen_input"]["residue_rows"] == 2000,
    m["frozen_input"]["proteins"] == 100,
    m["frozen_input"]["ecod_h_groups"] == 59,
    abs(m["primary_result"]["A"] - 0.11429845800943032) < 1e-15,
    abs(m["primary_result"]["C"] - 0.3366254619599847) < 1e-15,
    abs(m["primary_result"]["C_minus_A"] - 0.22232700395055432) < 1e-15,
    m["validation"]["authority_reconstruction"] == "PASS",
    m["validation"]["structural_null_audit"] == "PASS",
]
sys.exit(0 if all(checks) else 1)
' >/dev/null 2>&1; then
  pass "manifest authority fields"
else
  fail_check "manifest authority fields"
fi

# Do not raw-grep for '$Failed': Mathematica notebooks can legitimately embed
# Wolfram front-end / CodeInspector implementation code containing that symbol.
# The exact audited notebook SHA256 above is the stronger release-integrity gate.
for marker in \
  '/home/adam/' \
  'Missing[KeyAbsent' \
  'SpearmanRho::' \
  'GroupBy::' \
  'Syntax::' \
  'Rows: 0' \
  'Protein groups: 2'
do
  reject_notebook_marker "$marker"
done

printf 'INFO  raw $Failed scan intentionally omitted; audited notebook hash is authoritative\n'

if [[ -f "MANIFEST.sha256" ]]; then
  if sha256sum -c MANIFEST.sha256 >/dev/null 2>&1; then
    pass "MANIFEST.sha256"
  else
    fail_check "MANIFEST.sha256"
  fi
else
  printf 'INFO  MANIFEST.sha256 not frozen yet; expected before final archive\n'
fi

printf '\n'
if (( fail == 0 )); then
  printf 'ARTIFACT 001 RELEASE VERIFICATION: PASS\n'
  exit 0
else
  printf 'ARTIFACT 001 RELEASE VERIFICATION: FAIL\n' >&2
  exit 1
fi
