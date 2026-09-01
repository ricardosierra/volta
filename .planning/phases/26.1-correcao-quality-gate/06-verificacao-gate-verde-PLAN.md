---
phase: 26.1-correcao-quality-gate
plan: 6
type: execute
wave: 2
depends_on:
  - 01-inversao-camada-simulacao-PLAN
  - 02-refatoracao-seal-solver-PLAN
  - 03-divisao-arquivos-ui-PLAN
  - 04-promocao-config-fonte-unica-PLAN
  - 05-correcoes-pontuais-PLAN
files_modified:
  - docs/reports/quality-gate.md
autonomous: true
requirements:
  - QLT-06
must_haves:
  truths:
    - "./tools/ci/validate-repo.sh sai com código 0 e imprime OK nas 10 regras, sem nenhuma FALHA"
    - "./tools/ci/test-client.sh sai com código 0 — a refatoração não mudou comportamento"
    - "A dívida restante de ./tools/ci/lint.sh está quantificada e registrada, não escondida"
  artifacts:
    - path: "docs/reports/quality-gate.md"
      provides: "Registro datado da saída real dos três verificadores, com a saída colada literalmente"
      contains: "validate-repo"
      min_lines: 30
---

<objective>
Este é o plano que dá sentido a todos os outros. A Fase 26.1 existe por um motivo único e
objetivo: `./tools/ci/validate-repo.sh` estava vermelho em 5 regras (4, 6, 7, 8 e 10) desde
antes da Fase 26 — confirmado rodando o mesmo script no commit `cda85cc` num worktree
separado, com falhas idênticas.

Os planos 01 a 05 corrigiram uma parte cada. Este plano prova o conjunto, e não aceita
"deve estar bom": ou os três verificadores saem com código 0, ou a fase não fechou.

Purpose: verificar o gate inteiro e registrar a evidência com a saída literal.

Output: `docs/reports/quality-gate.md` com a saída real dos três comandos, datada.
</objective>

<execution_context>
@/Users/sierra/.claude/get-shit-done/workflows/execute-plan.md
@/Users/sierra/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@CLAUDE.md
@.planning/phases/26.1-correcao-quality-gate/26.1-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Rodar os três verificadores e registrar a saída literal</name>
  <files>docs/reports/quality-gate.md</files>
  <read_first>
    - tools/ci/validate-repo.sh (as 10 regras que serão verificadas)
    - .planning/phases/26.1-correcao-quality-gate/26.1-CONTEXT.md (o critério de pronto da fase)
    - CLAUDE.md §3 (as 10 regras e a ordem de execução dos scripts)
  </read_first>
  <action>
    Rode os três verificadores na ordem que o `CLAUDE.md` §3 manda, capturando a saída:

    ```bash
    cd /Users/sierra/Dev/Jogos/volta
    ./tools/ci/validate-repo.sh   > /tmp/gate_validate.txt 2>&1; echo "validate=$?"
    ./tools/ci/lint.sh            > /tmp/gate_lint.txt     2>&1; echo "lint=$? (esperado 1 — dívida pré-existente, ver ressalva)"
    ./tools/ci/test-client.sh     > /tmp/gate_tests.txt    2>&1; echo "tests=$?"
    ```

    **Se `validate-repo.sh` ou `test-client.sh` sair diferente de 0, PARE.** (`lint.sh` sai 1 por dívida de tipagem herdada das fases 2-9, fora do escopo desta fase — conte as violações e registre, não finja verde.) Não escreva o relatório, não marque nada como
    pronto, e reporte no SUMMARY exatamente qual regra continua vermelha e por quê. Um relatório
    afirmando verde com o verificador vermelho é precisamente o defeito que a auditoria de
    2026-08-31 encontrou nas fases 17 a 25 (`docs/reports/` tinha relatórios descrevendo testes
    que nunca rodaram). Não repita isso.

    Com os três em 0, escreva `docs/reports/quality-gate.md` com:

    - H1 `# Quality Gate — verificação da Fase 26.1` (obrigatório, o lint_docs.sh exige H1)
    - A data real da execução
    - Uma seção por verificador, com a saída **colada literalmente** dentro de bloco de código —
      não parafraseie, não resuma, não escreva "tudo OK". Cole o que o terminal imprimiu.
    - Uma tabela das 5 regras que estavam vermelhas (4, 6, 7, 8, 10), com o plano que corrigiu
      cada uma: 4 e 6 → plano 05; 7 → plano 01; 8 → planos 02 e 03; 10 → plano 04.
    - Uma seção `## O que este relatório NÃO afirma`, deixando explícito que o gate verde
      significa apenas conformidade com as 10 regras estruturais — **não** significa que o jogo
      funciona, que as fases 2-25 estão religadas, nem que houve teste em aparelho físico
      (`adb devices` continua vazio, gate F01-07 aberto).
  </action>
  <acceptance_criteria>
    - `./tools/ci/validate-repo.sh` sai com código 0
    - `./tools/ci/validate-repo.sh 2>&1 | grep -c FALHA` retorna 0
    - `./tools/ci/validate-repo.sh 2>&1 | grep -c '^OK'` retorna 10
    - `./tools/ci/lint.sh` tem MENOS violações do que antes da fase (eram 234; medir e registrar o número atual)
    - `./tools/ci/test-client.sh` sai com código 0
    - `test -f docs/reports/quality-gate.md` e `grep -c 'O que este relatório NÃO afirma' docs/reports/quality-gate.md` retorna 1
    - `./tools/ci/lint_docs.sh` sai com código 0
  </acceptance_criteria>
  <verify>
    <automated>./tools/ci/validate-repo.sh && [ "$(./tools/ci/validate-repo.sh 2>&1 | grep -c FALHA)" -eq 0 ] && [ "$(./tools/ci/lint.sh 2>&1 | grep -cE '^    apps/')" -lt 234 ] && ./tools/ci/test-client.sh && grep -q 'O que este relatório NÃO afirma' docs/reports/quality-gate.md && ./tools/ci/lint_docs.sh</automated>
  </verify>
  <done>Os três verificadores saem com código 0 e a saída literal está registrada em docs/reports/quality-gate.md, com as ressalvas explícitas do que o verde não significa.</done>
</task>

</tasks>

<verification>
- `./tools/ci/validate-repo.sh` — código 0, zero FALHA, 10 OK
- `./tools/ci/lint.sh` — dívida reduzida frente às 234 violações pré-existentes, número registrado
- `./tools/ci/test-client.sh` — código 0
- `docs/reports/quality-gate.md` contém a saída literal dos três, não paráfrase
</verification>

<success_criteria>
O quality gate que estava vermelho em 5 regras desde antes da Fase 26 está verde, com evidência
literal registrada e com as limitações do que esse verde significa declaradas de forma
explícita.
</success_criteria>

<output>
Crie `.planning/phases/26.1-correcao-quality-gate/26.1-06-SUMMARY.md` seguindo o template.
</output>
