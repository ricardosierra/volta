#!/usr/bin/env bash
# Sincroniza packages/shared/config -> apps/mobile/resources/config (fonte única -> projeto).
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
mkdir -p apps/mobile/resources/config
rsync -a --delete packages/shared/config/ apps/mobile/resources/config/ 2>/dev/null \
  || cp -R packages/shared/config/. apps/mobile/resources/config/
echo "OK: packages/shared/config sincronizado para apps/mobile/resources/config"
