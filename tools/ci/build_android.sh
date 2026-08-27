#!/usr/bin/env bash
# Exporta o APK de debug (ou falha explicando o que falta) via CLI do Godot.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

MODE="${1:-debug}"
GODOT_BIN="${GODOT_BIN:-}"
if [ -z "$GODOT_BIN" ]; then
  # Local canonico da engine nesta maquina e na CI (o mesmo caminho que o
  # workflow monta). O fallback antigo apontava para /Applications/Godot_CLI.app,
  # que era um Godot 4.3: o projeto declara 4.7 e rodar na 4.3 nao e "quase
  # certo", e outra engine.
  if [ -x "$HOME/.local/share/godot-bin/godot" ]; then GODOT_BIN="$HOME/.local/share/godot-bin/godot"
  elif command -v godot >/dev/null 2>&1; then GODOT_BIN=godot
  else echo "ERRO: binário do Godot não encontrado. Defina GODOT_BIN." >&2; exit 1
  fi
fi

./tools/ci/make_export_presets.sh
mkdir -p dist/android

case "$MODE" in
  debug)
    "$GODOT_BIN" --headless --path apps/mobile --export-debug "Android" ../../dist/android/volta-debug.apk
    code=$?
    ;;
  release)
    echo "build de release é GSD 21 (ANDR-001..003) — não implementado nesta fase." >&2
    exit 1
    ;;
  *)
    echo "modo desconhecido: $MODE (use 'debug')" >&2
    exit 1
    ;;
esac

if [ $code -eq 0 ] && [ -f dist/android/volta-debug.apk ]; then
  echo "✅ APK gerado em dist/android/volta-debug.apk"
else
  echo "❌ export falhou (exit $code). Verifique os export templates da versao em .godot-version e o Android SDK/JDK (tools/dev/doctor.sh)." >&2
  exit 1
fi
