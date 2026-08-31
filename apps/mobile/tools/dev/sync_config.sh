#!/usr/bin/env bash
# Sincroniza packages/shared/config -> apps/mobile/resources/config (fonte única -> projeto).
set -uo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mobile_dir="$(cd "$script_dir/../.." && pwd)"
repo_dir="$(cd "$mobile_dir/../.." && pwd)"
source_dir="$repo_dir/packages/shared/config"
target_dir="$mobile_dir/resources/config"

mkdir -p "$target_dir"
if command -v rsync >/dev/null 2>&1; then
	rsync -a "$source_dir/" "$target_dir/"
else
	cp -R "$source_dir/." "$target_dir/"
fi
echo "OK: $source_dir sincronizado para $target_dir"
