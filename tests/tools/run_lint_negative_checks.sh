#!/usr/bin/env bash
# Prova que lint.sh detecta de verdade a ausência de tipagem estática.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

FAIL=0
INJECTED=()
cleanup() { for f in "${INJECTED[@]}"; do rm -f "$f"; done; }
trap cleanup EXIT

check_case() {
  local desc="$1" src_fixture="$2" dest="$3" expect_grep="$4"
  cp "$src_fixture" "$dest"
  INJECTED+=("$dest")
  local out; out=$(./tools/ci/lint.sh 2>&1); local code=$?
  rm -f "$dest"
  if [ "$code" -eq 0 ]; then echo "FALHA NO TESTE NEGATIVO: '$desc' não fez lint.sh falhar."; FAIL=1; return; fi
  if ! echo "$out" | grep -q "$expect_grep"; then echo "FALHA NO TESTE NEGATIVO: '$desc' falhou sem a mensagem esperada."; FAIL=1; return; fi
  echo "OK (negativo provado): $desc"
}

check_case "var sem tipagem estática" tests/tools/fixtures/lint/untyped_var.gd apps/mobile/src/core/__negtest_lint_var.gd "sem tipagem estática"
check_case "parâmetro sem tipo" tests/tools/fixtures/lint/untyped_param.gd apps/mobile/src/core/__negtest_lint_param.gd "parâmetro"
check_case "retorno sem tipo" tests/tools/fixtures/lint/untyped_return.gd apps/mobile/src/core/__negtest_lint_return.gd "tipo de retorno"

echo ""
if [ $FAIL -eq 0 ]; then echo "✅ os 3 casos negativos de lint provaram a falha esperada."; else echo "❌ pelo menos um caso negativo de lint não provou a falha."; fi

final_out=$(./tools/ci/lint.sh 2>&1); final_code=$?
if [ $final_code -ne 0 ]; then echo "❌ lint.sh não voltou a passar limpo:"; echo "$final_out"; FAIL=1
else echo "✅ lint.sh volta a passar limpo depois da limpeza."; fi

exit $FAIL
