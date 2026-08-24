# GSD 24 — Critérios de aceite 🏁 RELEASE

## Checklist de release (de `docs/deployment/release-process.md`)

```text
[ ] 0 bugs blocker · 0 críticos
[ ] todos os quality gates fechados
[ ] testes verdes (unit, integration, gameplay, stress 5 000)
[ ] benchmarks dentro do orçamento, sem regressão > 10 %
[ ] migração de save testada a partir de todas as versões publicadas
[ ] VOLTA_DEBUG_TOOLS=false; nenhuma cena de debug no export
[ ] nenhum PLACEHOLDER ou MOCK vencido
[ ] nenhum TODO sem referência de tarefa
[ ] ícones, splash e launch screen corretos
[ ] safe area validada nos aparelhos extremos
[ ] textos revisados em en e pt-BR
[ ] política de privacidade publicada e ligada
[ ] Data Safety e Privacy Label coerentes com a coleta real
[ ] analytics validado ponta a ponta em produção
[ ] crash reporting recebendo eventos da build final
[ ] assets de loja prontos
[ ] plano de rollback escrito e ensaiado
[ ] tag anotada criada e CHANGELOG atualizado
```

## Da fase

| # | Critério | Como verificar |
|---|---|---|
| A24-01 | `v0.1.0` publicada nas duas lojas | lojas |
| A24-02 | Rollout gradual respeitado | Play Console |
| A24-03 | Crash-free ≥ 99,5 % em cada degrau | analytics |
| A24-04 | Nenhum bug crítico nas primeiras 72 h (ou hotfix publicado) | monitoramento |
| A24-05 | Avaliações respondidas | loja |
| A24-06 | Relatório de 72 h escrito | documento |
