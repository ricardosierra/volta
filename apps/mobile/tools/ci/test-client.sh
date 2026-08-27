#!/usr/bin/env bash
# Roda os testes GUT (unit + integration + gameplay) headless e propaga o exit code.
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mobile_dir="$(cd "$script_dir/../.." && pwd)"
cd "$mobile_dir" || exit 1

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

# --import primeiro: gera .godot/ e o cache de classes. Sem isso, a primeira execução
# headless num checkout limpo não resolve autoloads/class_name (verificado desde a 4.3; segue valendo na 4.7.2).
"$GODOT_BIN" --headless --path "$mobile_dir" --import >/dev/null 2>&1 || true
"$GODOT_BIN" --headless --path "$mobile_dir" -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
code=$?
if [ $code -eq 0 ]; then
  echo "✅ test-client: todos os testes GUT passaram."
else
  echo "❌ test-client: pelo menos um teste GUT falhou (exit $code)."
fi
exit $code
