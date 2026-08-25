#!/usr/bin/env bash
# Gera apps/mobile/export_presets.cfg a partir do template + variáveis de ambiente.
# O .cfg gerado NUNCA é versionado (ver .gitignore).
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

PACKAGE_NAME="${ANDROID_PACKAGE_NAME:-com.ricardosierra.volta}"
sed "s|__ANDROID_PACKAGE_NAME__|$PACKAGE_NAME|g" tools/ci/export_presets.template.cfg > apps/mobile/export_presets.cfg
echo "OK: apps/mobile/export_presets.cfg gerado (package: $PACKAGE_NAME)"
