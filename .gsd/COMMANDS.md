# Comandos de execução

Comandos conceituais. Qualquer um deles começa lendo `MASTER_PLAN.md` e `STATUS.md`.

---

## `Execute GSD XX`

Executa a fase indicada, do início ao fim.

```text
1.  ler .gsd/MASTER_PLAN.md e .gsd/STATUS.md
2.  ler .gsd/phases/XX-*/README.md, REQUIREMENTS.md, TASKS.md, ACCEPTANCE.md, TESTS.md, RISKS.md
3.  validar dependências em .gsd/DEPENDENCIES.md — se faltar algo, PARAR e reportar
4.  criar branch feature/gsd-XX-nome a partir de develop
5.  executar as tarefas na ordem declarada
6.  para cada tarefa: implementar → testar → commit semântico
7.  rodar a bateria da fase (TESTS.md)
8.  corrigir o que falhar
9.  atualizar documentação afetada (docs/ e .gsd/)
10. executar o quality gate (.gsd/QUALITY_GATES.md) e marcar cada item
11. escrever HANDOFF.md
12. atualizar STATUS.md e BACKLOG.md
13. abrir PR para develop com o HANDOFF no corpo
```

Não perguntar "e agora?" se o GSD já responde. Decisão técnica razoável dentro do escopo:
**decidir, documentar e seguir**.

---

## `Execute next GSD phase`

Lê `STATUS.md`, identifica a próxima fase pendente, valida dependências e roda o fluxo acima.

## `Resume current GSD phase`

Retoma de onde parou: lê `STATUS.md`, identifica a última tarefa concluída e continua na
seguinte. Não refaz trabalho já commitado.

## `Audit GSD XX`

Auditoria, **sem implementar nada novo**:

```text
- todas as tarefas estão realmente feitas?
- os critérios de aceite são verificáveis e foram verificados?
- os testes existem e passam?
- há regressão, código morto, duplicação?
- a arquitetura foi respeitada (camadas, tipagem, sem arquivos-depósito)?
- há TODO sem tarefa, mock sem fase de substituição, placeholder vencido?
- a documentação reflete o que foi feito?
- o orçamento de performance foi respeitado?
→ relatório + itens novos no BACKLOG.md
```

## `Show project status`

Imprime `STATUS.md` + progresso por fase + bloqueadores + próximo passo exato.

## `Plan GSD XX`

Revisa e detalha o plano de uma fase futura à luz do que já foi aprendido. Atualiza os
documentos da fase — **não** implementa.

---

## Regras que valem para todos os comandos

1. Nunca pular fase. Se a XX depende da YY e a YY não fechou, **parar e reportar**.
2. Nunca implementar fase futura "de brinde" durante a fase atual. Ideia boa vai para o `BACKLOG.md`.
3. Nunca marcar quality gate sem ter verificado de verdade.
4. Todo mock, placeholder e TODO nasce com fase e tarefa de substituição.
5. `STATUS.md` é atualizado ao fim de **toda** sessão de trabalho, mesmo interrompida.
