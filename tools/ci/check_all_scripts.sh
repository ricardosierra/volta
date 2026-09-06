#!/usr/bin/env bash
# Compila cada script .gd de apps/mobile/src e apps/mobile/tools, um por um.
#
# Existe porque check-project.sh dá falsa confiança: ele abre a cena principal, então só
# compila o que é alcançável a partir de root.gd. Arquivo que nenhuma cena referencia — e o
# projeto tem dezenas, das fases 3-25 que a auditoria de 2026-08-31 achou desligadas — pode
# estar quebrado há meses com os três gates verdes. Foi assim que uma limpeza de tipagem
# quebrou 10 arquivos sem nenhum check reclamar, e que dois arquivos com sintaxe de Godot 3
# sobreviveram desde a Fase 14 (GSD 02, Plano 02-07).
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

GODOT_BIN="${GODOT_BIN:-}"
if [ -z "$GODOT_BIN" ]; then
  if [ -x "$HOME/.local/share/godot-bin/godot" ]; then GODOT_BIN="$HOME/.local/share/godot-bin/godot"
  elif command -v godot >/dev/null 2>&1; then GODOT_BIN=godot
  else echo "ERRO: binário do Godot não encontrado. Defina GODOT_BIN." >&2; exit 1
  fi
fi

# --check-only --script não registra autoloads, então todo arquivo que usa Log ou Bootstrap
# reportaria "Identifier not found" falso. Filtramos exatamente esses dois nomes (os únicos
# autoloads do project.godot) e o erro em cascata que eles provocam.
IGNORE='Identifier not found: (Log|Bootstrap)|Failed to compile depended scripts'

failed=0
total=0
while IFS= read -r f; do
  total=$((total + 1))
  out=$("$GODOT_BIN" --headless --path apps/mobile --check-only --script "res://$f" 2>&1 \
        | grep -E 'Parse Error|Compile Error' | grep -vE "$IGNORE")
  if [ -n "$out" ]; then
    echo "❌ $f"
    echo "$out" | sed 's/^/      /'
    failed=$((failed + 1))
  fi
done < <(cd apps/mobile && find src tools -name '*.gd' | sort)

if [ "$failed" -gt 0 ]; then
  echo "❌ check-all-scripts: $failed de $total scripts não compilam." >&2
  exit 1
fi
echo "✅ check-all-scripts: $total scripts compilam."
