#!/usr/bin/env bash
# Roda os testes GUT (unit + integration + gameplay) headless e propaga o exit code.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

GODOT_BIN="${GODOT_BIN:-}"
if [ -z "$GODOT_BIN" ]; then
  if command -v godot >/dev/null 2>&1; then GODOT_BIN=godot
  elif [ -x "/Applications/Godot_CLI.app/Contents/MacOS/Godot" ]; then GODOT_BIN="/Applications/Godot_CLI.app/Contents/MacOS/Godot"
  else echo "ERRO: binário do Godot não encontrado. Defina GODOT_BIN." >&2; exit 1
  fi
fi

# --import primeiro: gera .godot/ e o cache de classes. Sem isso, a primeira execução
# headless num checkout limpo não resolve autoloads/class_name (verificado em 4.3.stable).
"$GODOT_BIN" --headless --path apps/mobile --import >/dev/null 2>&1 || true
"$GODOT_BIN" --headless --path apps/mobile -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
code=$?
if [ $code -eq 0 ]; then
  echo "✅ test-client: todos os testes GUT passaram."
else
  echo "❌ test-client: pelo menos um teste GUT falhou (exit $code)."
fi
exit $code
