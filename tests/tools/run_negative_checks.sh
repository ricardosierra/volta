#!/usr/bin/env bash
# Prova que validate-repo.sh detecta de verdade as 10 violações que promete.
# Cada caso injeta uma violação real, confirma a falha, remove, e no final confirma
# que o repositório volta a passar limpo.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

FAIL=0
INJECTED=()

cleanup() {
  for f in "${INJECTED[@]}"; do rm -f "$f"; done
  INJECTED=()
}
trap cleanup EXIT

check_case() {
  local desc="$1" file="$2" content="$3" expect_grep="$4"
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$content" > "$file"
  INJECTED+=("$file")
  local out
  out=$(./tools/ci/validate-repo.sh 2>&1)
  local code=$?
  rm -f "$file"
  INJECTED=("${INJECTED[@]/$file}")
  if [ "$code" -eq 0 ]; then
    echo "FALHA NO TESTE NEGATIVO: '$desc' não fez validate-repo.sh falhar (deveria)."
    FAIL=1
    return
  fi
  if ! echo "$out" | grep -q "$expect_grep"; then
    echo "FALHA NO TESTE NEGATIVO: '$desc' falhou, mas sem a mensagem esperada ('$expect_grep')."
    FAIL=1
    return
  fi
  echo "OK (negativo provado): $desc"
}

check_case "1. arquivo chamado utils.gd" \
  "apps/mobile/src/core/__negtest_dir/utils.gd" \
  "class_name NegtestUtils
extends RefCounted" \
  "arquivo-depósito proibido"

check_case "2. TODO sem (GSD-XX/TASK-YYY)" \
  "apps/mobile/src/core/__negtest_todo.gd" \
  "# TODO: consertar isso um dia
class_name NegtestTodo
extends RefCounted" \
  "TODO sem"

check_case "3. bloco MOCK sem Replacement Phase" \
  "apps/mobile/src/core/__negtest_mock.gd" \
  "## MOCK
## Replacement Task: TASK-999
class_name NegtestMock
extends RefCounted" \
  "MOCK sem Replacement"

check_case "4. PLACEHOLDER-ART-999 sem Replacement" \
  "apps/mobile/src/core/__negtest_placeholder.gd" \
  "# PLACEHOLDER-ART-999
class_name NegtestPlaceholder
extends RefCounted" \
  "PLACEHOLDER sem"

check_case "5. PLACEHOLDER com fase de destino já fechada" \
  "apps/mobile/src/core/__negtest_expired.gd" \
  "# PLACEHOLDER-ART-050 / Replacement: GSD 00
class_name NegtestExpired
extends RefCounted" \
  "fase de destino já fechada"

check_case "6. import de presentation/ dentro de territory/" \
  "apps/mobile/src/territory/__negtest_layer.gd" \
  "class_name NegtestLayer
extends RefCounted
const BAD := preload(\"res://src/presentation/camera/camera_rig.gd\")" \
  "camadas"

check_case "7. arquivo com 700 linhas" \
  "apps/mobile/src/core/__negtest_biggo.gd" \
  "$(printf 'class_name NegtestBiggo\nextends RefCounted\n'; for i in $(seq 1 700); do echo "# line $i"; done)" \
  "acima de 600 linhas"

check_case "8. link quebrado em docs/" \
  "docs/__negtest_broken_link.md" \
  "# Teste

[quebrado](./este-arquivo-nao-existe.md)" \
  "links quebrados"

check_case "9 (extra). função acima de 50 linhas" \
  "apps/mobile/src/core/__negtest_bigfunc.gd" \
  "$(printf 'class_name NegtestBigfunc\nextends RefCounted\nfunc _big() -> void:\n'; for i in $(seq 1 60); do echo "    pass # $i"; done)" \
  "função acima de 50 linhas"

check_case "10 (extra). dessincronia packages/shared/config" \
  "packages/shared/config/__negtest_desync.tres" \
  "[gd_resource type=\"Resource\"]" \
  "divergem"

echo ""
if [ $FAIL -eq 0 ]; then
  echo "✅ os 10 casos negativos provaram que validate-repo.sh falha quando deve."
else
  echo "❌ pelo menos um caso negativo não provou a falha esperada — validate-repo.sh tem um buraco."
fi

final_out=$(./tools/ci/validate-repo.sh 2>&1)
final_code=$?
if [ $final_code -ne 0 ]; then
  echo "❌ validate-repo.sh não voltou a passar limpo depois da limpeza dos casos negativos:"
  echo "$final_out"
  FAIL=1
else
  echo "✅ validate-repo.sh volta a passar limpo depois da limpeza."
fi

exit $FAIL
