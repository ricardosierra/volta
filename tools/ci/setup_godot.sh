#!/usr/bin/env bash
# Instala o editor Godot (headless) + export templates da versão dada, com cache local.
# Uso: ./tools/ci/setup_godot.sh 4.7.2.stable   (normalmente: $(cat .godot-version))
set -uo pipefail

VERSION="${1:?uso: setup_godot.sh <versao, ex. 4.7.2.stable>}"
# Tag e nomes de asset no GitHub usam hifen (4.7.2-stable); a pasta de export templates
# que o Godot procura usa ponto (4.7.2.stable). Nunca misture os dois.
TAG="${VERSION/.stable/-stable}"
CACHE_DIR="${GODOT_CACHE_DIR:-$HOME/.cache/godot-ci/$VERSION}"
BIN_PATH="$CACHE_DIR/Godot_v${TAG}_linux.x86_64"
TEMPLATES_DIR="$HOME/.local/share/godot/export_templates/${VERSION}"

mkdir -p "$CACHE_DIR"

if [ -x "$BIN_PATH" ]; then
  echo "OK: Godot $VERSION já em cache ($BIN_PATH)"
else
  echo "Baixando Godot $VERSION (editor headless, Linux)..."
  URL="https://github.com/godotengine/godot/releases/download/${TAG}/Godot_v${TAG}_linux.x86_64.zip"
  curl -fL -o "$CACHE_DIR/godot.zip" "$URL"
  unzip -o -q "$CACHE_DIR/godot.zip" -d "$CACHE_DIR"
  chmod +x "$BIN_PATH"
fi

if [ -d "$TEMPLATES_DIR" ] && [ -n "$(ls -A "$TEMPLATES_DIR" 2>/dev/null)" ]; then
  echo "OK: export templates $VERSION já em cache"
else
  echo "Baixando export templates $VERSION..."
  TPL_URL="https://github.com/godotengine/godot/releases/download/${TAG}/Godot_v${TAG}_export_templates.tpz"
  mkdir -p "$TEMPLATES_DIR"
  curl -fL -o "$CACHE_DIR/templates.tpz" "$TPL_URL"
  unzip -o -q "$CACHE_DIR/templates.tpz" -d "$CACHE_DIR/templates_tmp"
  cp -R "$CACHE_DIR"/templates_tmp/templates/. "$TEMPLATES_DIR"/
  rm -rf "$CACHE_DIR/templates_tmp"
fi

mkdir -p "$HOME/.local/bin"
ln -sf "$BIN_PATH" "$HOME/.local/bin/godot"
echo "$HOME/.local/bin" >> "${GITHUB_PATH:-/dev/null}" 2>/dev/null || true
echo "GODOT_BIN=$BIN_PATH" >> "${GITHUB_ENV:-/dev/null}" 2>/dev/null || true
echo "OK: godot disponível em $HOME/.local/bin/godot (GODOT_BIN=$BIN_PATH)"
