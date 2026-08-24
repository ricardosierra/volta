#!/usr/bin/env bash
# Verifica que apps/mobile abre headless sem erro nem warning de script.
# Godot 4.3: `--check-only` sem `--script` NÃO termina e `--quit` retorna 0 mesmo com erro,
# por isso rodamos --import + --quit e inspecionamos a saída.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
GODOT_BIN="${GODOT_BIN:-}"
if [ -z "$GODOT_BIN" ]; then
  if command -v godot >/dev/null 2>&1; then GODOT_BIN=godot
  elif [ -x "/Applications/Godot_CLI.app/Contents/MacOS/Godot" ]; then GODOT_BIN="/Applications/Godot_CLI.app/Contents/MacOS/Godot"
  else echo "ERRO: binário do Godot não encontrado. Defina GODOT_BIN." >&2; exit 1
  fi
fi
out=$("$GODOT_BIN" --headless --path apps/mobile --import 2>&1; "$GODOT_BIN" --headless --path apps/mobile --quit 2>&1)
# Exceção temporária e documentada (Plano 01-01 / Tarefa 2): apps/mobile/tests/**/*.gd usa
# `extends GutTest`, classe que só existe depois que o addon GUT for instalado no Plano 01-03
# (REPO-006). Até lá, --import não resolve a classe base e reporta os dois erros abaixo para
# CADA teste GUT já escrito — não é um bug do projeto. Remover este filtro no Plano 01-03.
filtered=$(echo "$out" | grep -v 'Could not find base class "GutTest"' \
  | grep -v 'Failed to load script "res://tests/.*" with error "Parse error"')
problems=$(echo "$filtered" | grep -E 'SCRIPT ERROR|ERROR:|WARNING:' || true)
if [ -n "$problems" ]; then
  echo "❌ check-project: apps/mobile reporta erro/aviso:"
  echo "$problems" | sed 's/^/    /'
  exit 1
fi
echo "✅ check-project: apps/mobile abre headless sem erro nem warning."
