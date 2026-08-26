#!/usr/bin/env bash
# Cada .md de docs/ e .gsd/ deve começar (primeira linha não-vazia) com um título "# ".
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

FAIL=0
for f in $(find docs .gsd -name '*.md' 2>/dev/null); do
  first_line=$(grep -m1 -v '^[[:space:]]*$' "$f" || true)
  case "$first_line" in
    "# "*) ;;
    *) echo "FALHA: $f não começa com um título H1 ('# ...'): '$first_line'"; FAIL=1 ;;
  esac
done
[ $FAIL -eq 0 ] && echo "OK: todos os docs começam com título H1"
exit $FAIL
