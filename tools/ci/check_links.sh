#!/usr/bin/env bash
# Verifica links relativos quebrados em arquivos Markdown de docs/ e .gsd/ e na raiz.
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

fail=0
while IFS= read -r file; do
  dir=$(dirname "$file")
  # extrai alvos de links markdown, ignorando http(s), mailto, âncoras puras e imagens externas
  grep -oE '\]\([^)]+\)' "$file" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' | while IFS= read -r target; do
    case "$target" in
      http://*|https://*|mailto:*|"#"*|"") continue ;;
    esac
    path="${target%%#*}"
    [ -z "$path" ] && continue
    if [ ! -e "$dir/$path" ]; then
      echo "LINK QUEBRADO  $file  ->  $target"
      echo "x" >> /tmp/volta_link_fail.$$
    fi
  done
done < <(find . -name '*.md' -not -path './.git/*' -not -path './services/api/vendor/*')

if [ -f "/tmp/volta_link_fail.$$" ]; then
  count=$(wc -l < "/tmp/volta_link_fail.$$" | tr -d ' ')
  rm -f "/tmp/volta_link_fail.$$"
  echo ""
  echo "FALHA: $count link(s) quebrado(s)."
  exit 1
fi
echo "OK: nenhum link relativo quebrado."
