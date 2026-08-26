#!/usr/bin/env bash
# Heurística de tipagem estática obrigatória em GDScript (CLAUDE.md regra 1).
# Não é um parser completo: cobre os 3 casos mais comuns de vazamento de tipagem.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

FAIL=0
GD_FILES=$(find apps packages services -name '*.gd' -not -path '*/addons/*' -not -path '*/tests/tools/fixtures/*' 2>/dev/null)

# 1. var sem tipo (nem ": Type" nem ":=") — aceita "var x: int = 5" e "var x := 5", rejeita "var x = 5"
untyped_var=$(echo "$GD_FILES" | xargs grep -nE '\bvar[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=' 2>/dev/null | grep -vE ':=' || true)
if [ -n "$untyped_var" ]; then
  echo "FALHA: var sem tipagem estática (nem ': Tipo' nem ':='):"
  echo "$untyped_var" | sed 's/^/    /'
  FAIL=1
fi

# 2. func sem "->" de retorno
untyped_return=$(echo "$GD_FILES" | xargs grep -nE '^\s*(static\s+)?func\s+[A-Za-z_][A-Za-z0-9_]*\s*\([^)]*\)\s*:' 2>/dev/null | grep -v '\->' || true)
if [ -n "$untyped_return" ]; then
  echo "FALHA: func sem tipo de retorno explícito ('-> Tipo'):"
  echo "$untyped_return" | sed 's/^/    /'
  FAIL=1
fi

# 3. parâmetro de func sem ":" (heurística: qualquer func com parênteses não-vazios
#    onde algum parâmetro, separado por vírgula, não contém ":")
untyped_param=$(echo "$GD_FILES" | while read -r f; do
  [ -z "$f" ] && continue
  grep -nE '^\s*(static\s+)?func\s+[A-Za-z_][A-Za-z0-9_]*\s*\(' "$f" | while IFS=: read -r lineno rest; do
    params=$(echo "$rest" | sed -E 's/^[^(]*\(([^)]*)\).*/\1/')
    [ -z "$params" ] && continue
    IFS=',' read -ra parts <<< "$params"
    for p in "${parts[@]}"; do
      trimmed=$(echo "$p" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
      [ -z "$trimmed" ] && continue
      if ! echo "$trimmed" | grep -q ':'; then
        echo "$f:$lineno: parâmetro sem tipo: '$trimmed'"
      fi
    done
  done
done)
if [ -n "$untyped_param" ]; then
  echo "FALHA: parâmetro de função sem tipo explícito:"
  echo "$untyped_param" | sed 's/^/    /'
  FAIL=1
fi

[ $FAIL -eq 0 ] && echo "OK: tipagem estática — nenhuma violação encontrada"
exit $FAIL
