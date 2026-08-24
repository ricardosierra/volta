#!/usr/bin/env bash
# Valida o ambiente de desenvolvimento do VOLTA.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
WARN=0

check() { # nome, comando, obrigatório-a-partir-de
  local name="$1" cmd="$2" since="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "  ✅ %-14s %s\n" "$name" "$($cmd --version 2>&1 | head -1)"
  else
    printf "  ⚠️  %-14s ausente (necessário a partir de %s)\n" "$name" "$since"; WARN=1
  fi
}

echo "VOLTA — verificação de ambiente"
echo ""
echo "Obrigatório agora:"
check git git "sempre"
echo ""
echo "A partir da GSD 01:"
if [ -f .godot-version ]; then
  want=$(cat .godot-version)
  if command -v godot >/dev/null 2>&1; then
    have=$(godot --version 2>&1 | head -1)
    printf "  ✅ %-14s %s (esperado: %s)\n" "godot" "$have" "$want"
    case "$have" in *"$want"*) ;; *) printf "     ⚠️  versão diferente da pinada\n"; WARN=1;; esac
  else
    printf "  ⚠️  %-14s ausente (esperado: %s)\n" "godot" "$want"; WARN=1
  fi
else
  printf "  ℹ️  %-14s .godot-version será criado em GSD 01 / REPO-001\n" "godot"
fi
echo ""
echo "A partir da GSD 15 (backend):"
check php php "GSD 15"
check composer composer "GSD 15"
check docker docker "GSD 15"
echo ""
echo "A partir da GSD 21/22 (release):"
check java java "GSD 21"
if [ "$(uname)" = "Darwin" ]; then check xcodebuild xcodebuild "GSD 22"; fi
echo ""
echo "Estrutura do repositório:"
./tools/ci/validate-repo.sh >/dev/null 2>&1 && echo "  ✅ validate-repo OK" || { echo "  ❌ validate-repo falhou — rode ./tools/ci/validate-repo.sh"; WARN=1; }
echo ""
[ $WARN -eq 0 ] && echo "Ambiente pronto." || echo "Ambiente utilizável, com avisos acima."
exit 0
