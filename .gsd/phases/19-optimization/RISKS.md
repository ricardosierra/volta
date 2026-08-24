# GSD 19 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F19-01 | Otimização introduzir bug sutil no território | 3 | 5 | 30 casos de mesa + 2 000 partidas após cada mudança; nenhuma otimização sem suíte verde |
| F19-02 | Otimizar o que não é gargalo | 3 | 2 | baseline obrigatório antes (PERF-001); lista priorizada por medição |
| F19-03 | Perda de qualidade visual sem perceber | 2 | 3 | comparação lado a lado em vídeo |
| F19-04 | Otimização de IA mudar comportamento | 3 | 3 | 500 partidas comparadas com o baseline; distribuição precisa ser equivalente |
| F19-05 | Orçamento inatingível em Low | 2 | 4 | preset Low pode reduzir efeitos; se ainda assim não fechar, ajustar o mínimo suportado (decisão de produto documentada) |
| F19-06 | GDExtension virar necessário e custar build multiplataforma | 2 | 4 | é a **última** estratégia da lista; só com medição que a justifique e ADR novo |

## Riscos globais tocados
- **RISK-004** (60 FPS) é resolvido ou vira decisão explícita de produto aqui.
