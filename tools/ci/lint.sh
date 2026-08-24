#!/usr/bin/env bash
# Lint de GDScript (tipagem estática) + lint de docs (título H1). Reúne e propaga exit code.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

FAIL=0
./tools/ci/lint_gdscript.sh || FAIL=1
./tools/ci/lint_docs.sh || FAIL=1

echo ""
if [ $FAIL -eq 0 ]; then echo "✅ lint: tudo certo."; else echo "❌ lint: corrija os itens acima."; fi
exit $FAIL
