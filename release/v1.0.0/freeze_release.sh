#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

printf '=== ARTIFACT 001 v1.0.0 FREEZE ===\n'

if [[ ! -x ./verify_artifact.sh ]]; then
  printf 'ERROR: verify_artifact.sh is missing or not executable.\n' >&2
  exit 1
fi

./verify_artifact.sh

printf '\n=== GENERATING MANIFEST.sha256 ===\n'

find . -maxdepth 1 -type f \
  ! -name 'MANIFEST.sha256' \
  -printf '%f\n' \
  | LC_ALL=C sort \
  | xargs sha256sum > MANIFEST.sha256

sha256sum -c MANIFEST.sha256

release_dir="$(pwd)"
version_dir="$(basename "$release_dir")"
release_parent="$(dirname "$release_dir")"
archive="$release_parent/artifact_001-${version_dir}.tar.gz"
archive_hash="$archive.sha256"

printf '\n=== CREATING RELEASE ARCHIVE ===\n'

tar -czf "$archive" -C "$release_parent" "$version_dir"
sha256sum "$archive" > "$archive_hash"

printf '\n=== RELEASE FROZEN ===\n'
printf 'Release directory: %s\n' "$release_dir"
printf 'Checksum manifest: %s/MANIFEST.sha256\n' "$release_dir"
printf 'Archive: %s\n' "$archive"
printf 'Archive checksum: %s\n' "$archive_hash"
printf '\n'
cat "$archive_hash"
