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

# tests/tools/fixtures/ guarda fixtures ESTÁTICAS de referência (ex.: Plano 01-08,
# tests/tools/fixtures/lint/*.gd) — nunca os testes injetados em runtime (esses são
# temporários e limpos pelo próprio harness que os cria). Excluídas do escaneamento normal.
exclude_fixtures() { grep -v '/tests/tools/fixtures/'; }

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

# apps/mobile/addons/**: dependências de terceiros pinadas (ex.: GUT, Plano 01-03/REPO-006).
# Não são código nosso — não seguem nossas convenções de nome/TODO/tamanho, e não devem.
VENDOR_PRUNE=(-path '*/addons/*' -prune -o)

echo "== 3. Nomes de arquivo proibidos =="
banned=$(find "${SRC_GLOBS[@]}" "${VENDOR_PRUNE[@]}" -type f \( -iname 'utils.gd' -o -iname 'helpers.gd' \
  -o -iname 'manager.gd' -o -iname 'global.gd' -o -iname 'misc.gd' -o -iname 'common.gd' \) -print 2>/dev/null | exclude_fixtures || true)
if [ -n "$banned" ]; then fail "arquivo-depósito proibido:"; echo "$banned" | sed 's/^/    /'
else ok "nenhum arquivo-depósito"; fi

echo "== 4. TODO com referência de tarefa =="
bad_todo=$(grep -rnE '(^|[^A-Za-z])TODO' --include='*.gd' --include='*.php' --include='*.sh' \
  "${SRC_GLOBS[@]}" 2>/dev/null | grep -v 'tools/ci/validate-repo.sh' \
  | grep -v '/addons/' \
  | grep -vE 'TODO\(GSD-[0-9]{2}/[A-Z0-9]+-[0-9]{3}\)' | exclude_fixtures || true)
if [ -n "$bad_todo" ]; then fail "TODO sem (GSD-XX/TASK-YYY):"; echo "$bad_todo" | sed 's/^/    /'
else ok "todo TODO tem referência de tarefa"; fi

echo "== 5. Mocks com fase de substituição =="
mock_files=$(grep -rln '## MOCK' --include='*.gd' --include='*.php' "${SRC_GLOBS[@]}" 2>/dev/null | exclude_fixtures || true)
bad_mock=""
for f in $mock_files; do
  grep -q 'Replacement Phase' "$f" && grep -q 'Replacement Task' "$f" || bad_mock="$bad_mock$f\n"
done
if [ -n "$bad_mock" ]; then fail "MOCK sem Replacement Phase/Task:"; printf "$bad_mock" | sed 's/^/    /'
else ok "todo mock tem fase de substituição"; fi

echo "== 6. Placeholders rastreados =="
ph=$(grep -rn 'PLACEHOLDER-[A-Z]*-[0-9]\{3\}' --include='*.gd' --include='*.tscn' --include='*.tres' \
  "${SRC_GLOBS[@]}" 2>/dev/null | exclude_fixtures || true)
bad_ph=$(echo "$ph" | grep -v 'Replacement: GSD [0-9]\{2\}' || true)
if [ -n "$ph" ] && [ -n "$bad_ph" ]; then fail "PLACEHOLDER sem 'Replacement: GSD XX':"; echo "$bad_ph" | sed 's/^/    /'
else ok "placeholders rastreados"; fi

closed_phases=$(grep -E '^\| [0-9]{2} \| ✅' .gsd/QUALITY_GATES.md | sed -E 's/^\| ([0-9]{2}).*/\1/')
expired_ph=""
for gsd_num in $(echo "$ph" | grep -oE 'Replacement: GSD [0-9]{2}' | grep -oE '[0-9]{2}' | sort -u); do
  if echo "$closed_phases" | grep -qx "$gsd_num"; then
    expired_ph="$expired_ph$(echo "$ph" | grep "Replacement: GSD $gsd_num")\n"
  fi
done
if [ -n "$expired_ph" ]; then
  fail "PLACEHOLDER com fase de destino já fechada (deveria ter sido substituído):"
  printf "$expired_ph" | sed 's/^/    /'
fi

echo "== 7. Regra de camadas (simulação não conhece apresentação) =="
if [ -d apps/mobile/src ]; then
  viol=$(grep -rn 'presentation/\|res://src/ui/' apps/mobile/src/territory apps/mobile/src/runner \
    apps/mobile/src/ai apps/mobile/src/gameplay 2>/dev/null | exclude_fixtures || true)
  if [ -n "$viol" ]; then fail "simulação referenciando apresentação/UI:"; echo "$viol" | sed 's/^/    /'
  else ok "camadas respeitadas"; fi
else
  note "pulado: projeto Godot ainda não existe (criado em GSD 01 / REPO-001)"
fi

echo "== 8. Tamanho de arquivo =="
if have_code; then
  big=$(find "${SRC_GLOBS[@]}" "${VENDOR_PRUNE[@]}" \( -name '*.gd' -o -name '*.php' \) -print 2>/dev/null | exclude_fixtures | while read -r f; do
    n=$(wc -l < "$f"); [ "$n" -gt 600 ] && echo "$f ($n linhas)"; done)
  if [ -n "$big" ]; then fail "arquivo acima de 600 linhas:"; echo "$big" | sed 's/^/    /'
  else ok "nenhum arquivo acima de 600 linhas"; fi

  # heurística: distância entre 'func' consecutivos; não lida com funções
  # aninhadas ou lambdas multi-linha longas dentro de uma func curta.
  big_func=$(find apps packages services "${VENDOR_PRUNE[@]}" -name '*.gd' -print 2>/dev/null | exclude_fixtures | while read -r f; do
    awk -v file="$f" '
      /^func |^static func / { if (start) { len = NR - start; if (len > 50) print file":"start" ("len" linhas)" }; start = NR }
      END { if (start) { len = NR - start + 1; if (len > 50) print file":"start" ("len" linhas)" } }
    ' "$f"
  done)
  if [ -n "$big_func" ]; then fail "função acima de 50 linhas:"; echo "$big_func" | sed 's/^/    /'
  else ok "nenhuma função acima de 50 linhas"; fi
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

echo "== 10. Sincronia packages/shared/config <-> apps/mobile/resources/config =="
if [ -d packages/shared/config ] && [ -d apps/mobile/resources/config ]; then
  sync_diff=$(diff -rq packages/shared/config apps/mobile/resources/config 2>&1 || true)
  if [ -n "$sync_diff" ]; then
    fail "packages/shared/config e apps/mobile/resources/config divergem:"
    echo "$sync_diff" | sed 's/^/    /'
  else
    ok "config sincronizada"
  fi
else
  note "pulado: um dos dois diretórios ainda não existe (ConfigService criado em GSD 01 / REPO-005)"
fi

echo ""
if [ $FAIL -eq 0 ]; then echo "✅ validate-repo: tudo certo."; else echo "❌ validate-repo: corrija os itens acima."; fi
exit $FAIL
