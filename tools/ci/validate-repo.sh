#!/usr/bin/env bash
# Valida as regras estruturais do repositório VOLTA.
# Estas regras estão descritas em CONTRIBUTING.md e são obrigatórias.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

FAIL=0
note() { echo "  $*"; }
fail() { echo "FALHA: $*"; FAIL=1; }
ok()   { echo "OK: $*"; }

SRC_GLOBS=(apps packages services tools tests)
have_code() { [ -d apps/mobile/src ] || [ -d services/api/app ]; }

echo "== 1. Estrutura obrigatória =="
for d in apps/mobile services/api packages/shared assets tools tests docs .gsd .github; do
  [ -d "$d" ] || fail "diretório ausente: $d"
done
for f in README.md LICENSE CONTRIBUTING.md CHANGELOG.md CODE_OF_CONDUCT.md SECURITY.md \
         .editorconfig .gitignore .env.example docs/INDEX.md \
         .gsd/MASTER_PLAN.md .gsd/STATUS.md .gsd/DEPENDENCIES.md .gsd/DECISIONS.md \
         .gsd/RISKS.md .gsd/QUALITY_GATES.md .gsd/BACKLOG.md; do
  [ -f "$f" ] || fail "arquivo ausente: $f"
done
[ $FAIL -eq 0 ] && ok "estrutura completa"

echo "== 2. Fases GSD com os 7 documentos =="
missing=0
for p in .gsd/phases/*/; do
  for f in README REQUIREMENTS TASKS ACCEPTANCE TESTS RISKS HANDOFF; do
    [ -f "$p$f.md" ] || { fail "faltando $p$f.md"; missing=1; }
  done
done
[ $missing -eq 0 ] && ok "$(ls -d .gsd/phases/*/ | wc -l | tr -d ' ') fases com 7 documentos cada"

echo "== 3. Nomes de arquivo proibidos =="
banned=$(find "${SRC_GLOBS[@]}" -type f \( -iname 'utils.gd' -o -iname 'helpers.gd' \
  -o -iname 'manager.gd' -o -iname 'global.gd' -o -iname 'misc.gd' -o -iname 'common.gd' \) 2>/dev/null || true)
if [ -n "$banned" ]; then fail "arquivo-depósito proibido:"; echo "$banned" | sed 's/^/    /'
else ok "nenhum arquivo-depósito"; fi

echo "== 4. TODO com referência de tarefa =="
bad_todo=$(grep -rnE '(^|[^A-Za-z])TODO' --include='*.gd' --include='*.php' --include='*.sh' \
  "${SRC_GLOBS[@]}" 2>/dev/null | grep -v 'tools/ci/validate-repo.sh' \
  | grep -vE 'TODO\(GSD-[0-9]{2}/[A-Z0-9]+-[0-9]{3}\)' || true)
if [ -n "$bad_todo" ]; then fail "TODO sem (GSD-XX/TASK-YYY):"; echo "$bad_todo" | sed 's/^/    /'
else ok "todo TODO tem referência de tarefa"; fi

echo "== 5. Mocks com fase de substituição =="
mock_files=$(grep -rln '## MOCK' --include='*.gd' --include='*.php' "${SRC_GLOBS[@]}" 2>/dev/null || true)
bad_mock=""
for f in $mock_files; do
  grep -q 'Replacement Phase' "$f" && grep -q 'Replacement Task' "$f" || bad_mock="$bad_mock$f\n"
done
if [ -n "$bad_mock" ]; then fail "MOCK sem Replacement Phase/Task:"; printf "$bad_mock" | sed 's/^/    /'
else ok "todo mock tem fase de substituição"; fi

echo "== 6. Placeholders rastreados =="
ph=$(grep -rn 'PLACEHOLDER-[A-Z]*-[0-9]\{3\}' --include='*.gd' --include='*.tscn' --include='*.tres' \
  "${SRC_GLOBS[@]}" 2>/dev/null || true)
bad_ph=$(echo "$ph" | grep -v 'Replacement: GSD [0-9]\{2\}' || true)
if [ -n "$ph" ] && [ -n "$bad_ph" ]; then fail "PLACEHOLDER sem 'Replacement: GSD XX':"; echo "$bad_ph" | sed 's/^/    /'
else ok "placeholders rastreados"; fi

echo "== 7. Regra de camadas (simulação não conhece apresentação) =="
if [ -d apps/mobile/src ]; then
  viol=$(grep -rn 'presentation/\|res://src/ui/' apps/mobile/src/territory apps/mobile/src/runner \
    apps/mobile/src/ai apps/mobile/src/gameplay 2>/dev/null || true)
  if [ -n "$viol" ]; then fail "simulação referenciando apresentação/UI:"; echo "$viol" | sed 's/^/    /'
  else ok "camadas respeitadas"; fi
else
  note "pulado: projeto Godot ainda não existe (criado em GSD 01 / REPO-001)"
fi

echo "== 8. Tamanho de arquivo =="
if have_code; then
  big=$(find "${SRC_GLOBS[@]}" -name '*.gd' -o -name '*.php' 2>/dev/null | while read -r f; do
    n=$(wc -l < "$f"); [ "$n" -gt 600 ] && echo "$f ($n linhas)"; done)
  if [ -n "$big" ]; then fail "arquivo acima de 600 linhas:"; echo "$big" | sed 's/^/    /'
  else ok "nenhum arquivo acima de 600 linhas"; fi
else
  note "pulado: nenhum código ainda"
fi

echo "== 9. Links de documentação =="
if ./tools/ci/check_links.sh > /tmp/volta_links.$$ 2>&1; then
  ok "links de documentação"
else
  fail "links quebrados:"; sed 's/^/    /' /tmp/volta_links.$$
fi
rm -f /tmp/volta_links.$$

echo ""
if [ $FAIL -eq 0 ]; then echo "✅ validate-repo: tudo certo."; else echo "❌ validate-repo: corrija os itens acima."; fi
exit $FAIL
