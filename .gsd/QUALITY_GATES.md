# Quality Gates

> Uma fase **não** está concluída porque o código compila. Está concluída quando todos os itens
> abaixo forem verdade — verificados, não presumidos.

## Gate universal (toda fase)

```text
[ ] implementação completa (todas as tarefas do TASKS.md fechadas)
[ ] testes passando (unit + integration + gameplay da fase)
[ ] nenhum warning crítico no editor nem no CI
[ ] documentação atualizada (docs/ e .gsd/ afetados)
[ ] critérios de aceite do ACCEPTANCE.md satisfeitos e verificados
[ ] nenhum bloqueador em aberto
[ ] performance mobile aceitável (orçamento respeitado nas fases que tocam o caminho quente)
[ ] código revisado
[ ] arquitetura respeitada (camadas, tipagem, sem arquivo-depósito, sem literal de gameplay)
[ ] nenhum TODO sem referência de tarefa
[ ] nenhum mock sem Replacement Phase + Replacement Task
[ ] nenhum placeholder além da fase declarada de substituição
[ ] HANDOFF.md escrito
[ ] STATUS.md atualizado
[ ] BACKLOG.md atualizado com o que foi adiado
```

## Gates adicionais por tipo de fase

### Fases com representação visual (02, 07, 08, 09, 11, 13, 20)

```text
[ ] alinhamento e espaçamento seguem os tokens do design system
[ ] toda ação tem feedback visual em < 100 ms
[ ] contraste mínimo respeitado (4,5:1 texto, 3:1 UI)
[ ] legível em todos os temas, inclusive Monochrome
[ ] responsivo de 16:9 a 20:9 e em tablet
[ ] safe area respeitada em todas as telas
[ ] nenhuma transição acima de 300 ms
[ ] sobrevive a UI scale 1,25 sem sobreposição
[ ] aparência mobile premium: nada parece placeholder de engine
```

### Fases com interação principal (03, 04, 06, 09, 12, 14)

Contrato de game feel — os sete canais:

```text
[ ] Gameplay     a mecânica funciona e é justa
[ ] Animation    tem animação própria, com curva definida
[ ] VFX          tem efeito visual proporcional ao evento
[ ] SFX          tem som, com variações contra fadiga
[ ] Haptics      tem padrão háptico, respeitando as settings
[ ] Camera       tem resposta de câmera, escalada por Reduce shake
[ ] UI Feedback  tem retorno na HUD, sem poluir
```

> Uma captura matematicamente correta e visualmente sem impacto é uma implementação
> **incompleta** — reprova o gate.

### Fases de simulação (03, 04, 05, 12, 13, 14)

```text
[ ] invariantes verdes em 500 partidas headless
[ ] zero crash, zero território inválido, zero partida infinita
[ ] determinismo: mesma seed → mesmo resultado, 10 execuções
[ ] benchmarks dentro do orçamento; nenhuma regressão > 10 %
[ ] nenhuma alocação nova no caminho quente
```

### Fases de backend (15, 16)

```text
[ ] Pint e PHPStan (nível 6+) limpos
[ ] Pest verde, incluindo casos de erro e de rate limit
[ ] migrações reversíveis e testadas
[ ] nenhuma rota sem validação e sem rate limit
[ ] nenhum segredo no repositório
[ ] escritas idempotentes
[ ] backup e restauração testados
```

### Fases de release (21, 22, 23, 24)

```text
[ ] build de release sem ferramentas de debug
[ ] assinatura válida e reprodutível pelo CI
[ ] ícones, splash e launch screen corretos em todas as densidades
[ ] tamanho do app dentro do orçamento
[ ] testado em dispositivo real da matriz
[ ] metadados e política de privacidade coerentes com a coleta real
[ ] plano de rollback escrito e ensaiado
```

## Registro

| Fase | Gate | Data | Observações |
|---|---|---|---|
| 00 | ✅ fechado | 2026-08-24 | Master Plan READY; 14 ADRs aceitos; nenhuma decisão fundamental em aberto |
| 01 | ⬜ | | |
| 02 | 🟡 parcial | 2026-09-05 | 7 planos executados, 127 testes verdes, 4 gates de CI limpos. **MOV-05 REPROVADO** em Galaxy S23: p95 108-126 ms contra meta de 50 ms (`docs/performance/device-results.md`). Bug de UI engolindo o toque achado e corrigido no aparelho. FPS Mid/Low e teste de sensação pendentes. |
| 03 | ⬜ | | |
| 04 | ⬜ | | |
| 05 | ⬜ | | |
| 06 | ⬜ | | |
| 07 | ⬜ | | |
| 08 | ⬜ | | |
| 09 | ⬜ | | |
| 10 | ⬜ | | |
| 11 | ⬜ | | |
| 12 | ⬜ | | |
| 13 | ⬜ | | |
| 14 | ⬜ | | |
| 15 | ⬜ | | |
| 16 | ⬜ | | |
| 17 | ⬜ | | |
| 18 | ⬜ | | |
| 19 | ⬜ | | |
| 20 | ⬜ | | |
| 21 | ⬜ | | |
| 22 | ⬜ | | |
| 23 | ⬜ | | |
| 24 | ⬜ | | |
| 25 | ⬜ | | |
