#!/usr/bin/env bash
# Verifica que apps/mobile abre headless sem erro nem warning de script.
# `--check-only` sem `--script` NAO termina e `--quit` retorna 0 mesmo com erro,
# por isso rodamos --import + --quit e inspecionamos a saída.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
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
out=$("$GODOT_BIN" --headless --path apps/mobile --import 2>&1; "$GODOT_BIN" --headless --path apps/mobile --quit 2>&1)
problems=$(echo "$out" | grep -E 'SCRIPT ERROR|ERROR:|WARNING:' || true)
if [ -n "$problems" ]; then
  echo "❌ check-project: apps/mobile reporta erro/aviso:"
  echo "$problems" | sed 's/^/    /'
  exit 1
fi
echo "✅ check-project: apps/mobile abre headless sem erro nem warning."
