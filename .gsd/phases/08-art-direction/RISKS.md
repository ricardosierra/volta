# GSD 08 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F08-01 | **Beleza comer legibilidade** (Pilar 3) | 3 | 5 | hierarquia visual normativa; auditoria ART-010; teste cego de ameaça com meta de 90 % |
| F08-02 | Arte não fechar e o jogo continuar parecendo protótipo (RISK-016) | 2 | 4 | arte vetorial/procedural é barata de produzir e iterar; placeholders reprovam o gate |
| F08-03 | Shaders estourarem o orçamento de GPU | 3 | 4 | orçamento por efeito em `art/vfx.md`; medição em dispositivo, não em desktop; presets como válvula |
| F08-04 | Fonte sem licença comercial adequada | 2 | 4 | escolha com licença verificada e registrada em `CREDITS.md`; decisão humana H-04 |
| F08-05 | Tema desequilibrado dar vantagem competitiva | 2 | 3 | auditoria de equilíbrio na ART-006; nenhum tema pode destacar Arc inimigo |
| F08-06 | Preset `Auto` errar e dar má primeira impressão | 3 | 3 | micro-benchmark no boot + valor salvo + sobrescrita manual visível nas settings |
| F08-07 | Semelhança visual acidental com outro jogo | 2 | 4 | direção própria documentada; revisão explícita no gate; nenhum asset de terceiros |

## Riscos globais tocados
- **RISK-016** (parecer protótipo) morre aqui.
- **RISK-004** (60 FPS): a arte é o maior consumidor de GPU.
