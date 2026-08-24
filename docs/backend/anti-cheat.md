# Anti-cheat

> Não existe anti-cheat perfeito em jogo mobile single-player com leaderboard. Existe **custo
> de ataque** e **contenção de dano**. O objetivo é que o leaderboard seja confiável o
> suficiente para ser divertido, sem punir jogador legítimo por engano.

## Modelo de ameaça

| Ataque | Probabilidade | Impacto | Defesa |
|---|---|---|---|
| Editar o save local | alta | baixo (local) | fonte de verdade é o servidor |
| Forjar submissão de score | alta | **alto** | validação de plausibilidade + HMAC + recálculo |
| Repetir submissão (replay) | média | médio | idempotência + `match_id` único |
| Acelerar o app (speed hack) | média | alto | validação de duração × eventos |
| Modificar o APK | média | alto | validação no servidor; integridade de plataforma (opcional) |
| Automação / bot farm | baixa | médio | detecção de padrão + rate limit |
| Abuso de IAP | baixa | alto | validação de recibo |

## Validação de plausibilidade

Toda partida submetida passa por um conjunto de limites derivados das **regras físicas do jogo**:

```text
duration_ms       dentro da faixa do modo (+ tolerância)
claim_pct         ∈ [0, 1]; e coerente com duration (existe uma taxa máxima de captura possível)
seals             ≤ duration_s / tempo mínimo entre Seals
breaks            ≤ runners_no_modo × mortes possíveis na duração
score             recalculado a partir dos agregados; divergência ≤ tolerância
max_surge         ≤ teto do sistema
largest_seal_pct  ≤ claim_pct
```

Falha → `422`, partida registrada com `flags`, **sem** banimento automático. Padrão repetido
entra em revisão.

## Escala de resposta

| Nível | Gatilho | Ação |
|---|---|---|
| 1 | 1 partida implausível | rejeita a partida, registra |
| 2 | 5 em 24 h | shadow: score não entra no leaderboard público, jogador não é avisado |
| 3 | padrão persistente | remoção das entradas + revisão manual |
| 4 | fraude confirmada de compra | bloqueio de conta |

Nunca banimos por uma única anomalia. Falso positivo custa mais caro que um trapaceiro no
top 100 por um dia.

## Leaderboard

- Sanitização de apelido (lista de bloqueio + normalização de Unicode; nada de homóglifos).
- Recorde só entra depois de processado pela fila, nunca direto pela requisição.
- Boards diário/semanal/mensal reduzem o valor de um recorde fraudado (a janela expira).
- Board `all_time` tem revisão humana no top 10 antes de ser exibido publicamente.

## Futuro (GSD 17, multiplayer)

Com servidor autoritativo, o problema muda de natureza: a simulação acontece no servidor e o
cliente só envia **input**. Validações passam a ser sobre plausibilidade de input (taxa de
troca de direção, timestamps), não sobre resultado.

## O que NÃO vamos fazer

- ❌ Detecção invasiva de root/jailbreak que quebra jogador legítimo.
- ❌ Coleta de dados extras "para segurança" que violem a política de privacidade.
- ❌ Banir por heurística única, sem histórico.
- ❌ Ofuscar o save a ponto de impossibilitar suporte ao jogador.
