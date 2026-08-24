# GSD 00 — Critérios de aceite

| # | Critério | Como verificar | Status |
|---|---|---|---|
| A00-01 | O repositório existe, com estrutura completa e git inicializado | `git log`, `tree` | ✅ |
| A00-02 | README explica o projeto sem exigir conversa com o autor | leitura externa | ✅ |
| A00-03 | Existem ≥ 35 documentos cobrindo produto, design, gameplay, arquitetura, UI, arte, áudio, testes, performance, backend e deploy | `find docs -name '*.md' \| wc -l` = 63 | ✅ |
| A00-04 | Existem ≥ 5 ADRs no formato exigido | 14 ADRs com Context/Decision/Alternatives/Consequences/Status | ✅ |
| A00-05 | O sistema de território está especificado a ponto de ser implementável sem novas decisões | `docs/architecture/territory-system.md` + ADR-0002 | ✅ |
| A00-06 | As regras do jogo são normativas e numeradas | `docs/gameplay/rules.md` | ✅ |
| A00-07 | Todos os números de balanceamento estão fora do código, em um documento único | `docs/design/balance.md` | ✅ |
| A00-08 | Existem 26 fases, cada uma com 7 documentos | `ls .gsd/phases/*/` | ✅ |
| A00-09 | Toda tarefa tem ID, objetivo, contexto, dependências, arquivos, passos, testes e DoD | inspeção de `TASKS.md` | ✅ |
| A00-10 | Dependências entre fases estão mapeadas, incluindo as externas com dono humano | `.gsd/DEPENDENCIES.md` | ✅ |
| A00-11 | Quality gates definidos, incluindo gates por tipo de fase | `.gsd/QUALITY_GATES.md` | ✅ |
| A00-12 | Riscos com P × I, mitigação e dono; os de score ≥ 12 têm ação embutida no plano | `.gsd/RISKS.md` | ✅ |
| A00-13 | Backlog inicial com placeholders e mocks já rastreados e com fase de destino | `.gsd/BACKLOG.md` | ✅ |
| A00-14 | **Nenhuma fase depende de decisão fundamental não tomada** | varredura de `.gsd/phases/*/RISKS.md` e `DECISIONS.md` | ✅ |
| A00-15 | Nada no plano é cópia de terceiros | revisão do próprio material; glossário e regras próprios | ✅ |
