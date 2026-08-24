# GSD 11 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F11-01 | Um cosmético dar vantagem sem ninguém perceber | 2 | 5 | testes de equidade automatizados (hitbox, largura, duração, custo) + auditoria COSM-008 |
| F11-02 | Skin prejudicar a legibilidade em algum tema | 3 | 3 | matriz item × tema com capturas; teste cego de ameaça |
| F11-03 | Catálogo inchar e o app crescer | 2 | 3 | assets vetoriais/procedurais; orçamento de tamanho monitorado |
| F11-04 | Dark pattern entrar "sem querer" na tela de compra | 2 | 4 | revisão item a item contra a lista de proibições de `monetization.md` |
| F11-05 | Preço mal calibrado tornar a coleção inalcançável | 3 | 3 | `economy_sim` rodado de novo com o catálogo real |

## Riscos globais tocados
- **RISK-005**: cosméticos são um dos motores de retenção — mas nunca à custa de justiça.
