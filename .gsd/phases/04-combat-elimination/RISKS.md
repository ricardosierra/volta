# GSD 04 — Riscos da fase

| # | Risco | P | I | Mitigação |
|---|---|---|---|---|
| F04-01 | Colisão perdida quando o Runner atravessa várias células num tick | 3 | 5 | usar o mesmo traçado supercover do Arc para a checagem de colisão; teste com velocidade extrema |
| F04-02 | Backwash virar rota de fuga (RISK-007) | 3 | 3 | reinício imediato do Arc (R6.4) com teste dedicado; frequência medida no stress test como baseline |
| F04-03 | Mortes parecerem arbitrárias e ferirem o Pilar 1 | 3 | 4 | lista fechada de causas (R5.7); aviso periférico (CMBT-008); teste de sensação com meta de 90 % |
| F04-04 | Respawn injusto (em cima de inimigo, ou em canto sem espaço) | 3 | 3 | regra de distância mínima + fallback que nunca falha; teste de 1 000 respawns em mapa lotado |
| F04-05 | Simultaneidade produzir estado inconsistente | 3 | 4 | ordem de tick fixada e documentada (CMBT-007); casos de teste específicos |
| F04-06 | Território não liberado corretamente na morte | 2 | 4 | invariante de soma verde após cada morte no stress test |
| F04-07 | Repulsão Runner×Runner empurrar alguém para dentro do próprio Arc, causando Backwash injusto | 2 | 3 | repulsão suave, limitada, e nunca aplicada a quem está em `DrawingTrail` perto do próprio Arc |

## Riscos globais tocados

- **RISK-007** (Backwash degenerado): baseline medido aqui, decisão de ajuste na GSD 19.
- **RISK-005** (jogo não divertido): o primeiro momento em que existe tensão real — o teste de
  sensação já vale como sinal precoce.
