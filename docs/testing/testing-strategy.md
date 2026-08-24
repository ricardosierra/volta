# Estratégia de testes

> "Compilou" não é teste. "Rodei uma vez" não é teste. O que segura este projeto é a
> simulação ser **determinística e headless** — isso permite testar o jogo de verdade, não só
> funções isoladas.
>
> Stack: [`ADR-0013`](../decisions/ADR-0013-testing-stack.md) — GUT para unit/integration,
> runner headless próprio para gameplay e stress.

## Pirâmide

```text
        ╱ Stress ╲          500–5 000 partidas headless (noturno, CI semanal)
      ╱ Gameplay  ╲         partidas completas com bots, invariantes (CI por PR, amostra)
    ╱ Integration   ╲       fluxos entre sistemas (CI por PR)
  ╱      Unit         ╲     geometria, score, save, config, FSM (CI por PR)
```

## 1. Unit

| Alvo | Exemplos |
|---|---|
| `SealSolver` | região simples, côncava, contra a borda, com buraco, sem área, roubo, Arc inimigo engolido |
| Rasterização de Arc | conectividade 4-vizinhos em movimentos aleatórios (teste de propriedade) |
| `TerritoryGrid` | contagem incremental, reset, serialização round-trip |
| Score | cada termo isolado, tetos, determinismo |
| Surge | subida, decaimento, zeragem, teto |
| FSM | toda transição válida + rejeição de inválidas |
| Save | round-trip, corrupção, migração, versão futura |
| Config | validação de faixa, coerência entre arquivos |
| Economia | fórmulas de XP e Sparks, tetos |

Meta de cobertura: **≥ 85 %** em `territory/`, `gameplay/score/`, `core/save/`.
Nas demais, cobertura não é meta — comportamento coberto é.

## 2. Integration

| Fluxo | O que valida |
|---|---|
| Sair → desenhar → fechar | estado, grid, evento, score, análise |
| Corte de Arc por inimigo | morte, crédito, liberação de território |
| Backwash | Arc reiniciado, penalidade, Surge zerado, **continua vulnerável** |
| Squeeze | eliminação por território zerado + respawn |
| Ciclo de partida | Boot → Menu → Loading → Countdown → Playing → Results → Loading |
| Pause | simulação congelada, nada expira, retomada limpa |
| Respawn | local válido, invulnerabilidade, contadores |
| Coleta de power-up | aplicação, expiração, remoção limpa do `StatBlock` |
| Save no ciclo | fim de partida grava XP, Sparks, estatísticas e conquistas |

## 3. Gameplay (headless)

Partidas completas, sem render, com bots em todos os assentos:

```bash
./tools/dev/simulate.sh 500 --mode classic --seed 42 --report .reports/sim.json
```

**Invariantes verificadas a cada tick de cada partida:**

```text
[ ] soma de células por dono + neutras + bloqueadas == total do grid
[ ] nenhum Runner em Safe com arc_length > 0
[ ] todo Arc é 4-conectado
[ ] nenhum Runner fora dos limites do Field
[ ] nenhum estado dura mais que o máximo permitido
[ ] partida termina dentro do tempo máximo do modo
[ ] score é monotônico não decrescente durante a partida
[ ] nenhuma alocação de grid depois do setup
```

Falha de invariante grava o **estado serializado** (`§10` do território) para reprodução exata.

## 4. Stress

Ver [`stress-testing.md`](stress-testing.md).

## 5. Performance

Benchmarks com orçamento — ver [`../performance/territory-benchmarks.md`](../performance/territory-benchmarks.md).
Regressão acima de 10 % em relação ao baseline **falha o CI**.

## 6. Manual / QA

Checklist por fase em `.gsd/phases/XX/TESTS.md`, e checklist de dispositivo em
[`../mobile/device-matrix.md`](../mobile/device-matrix.md). Playtest com pessoas de fora nos
gates de Alpha e Beta — sem instruções verbais, gravando a tela e a mão.

## 7. Regras

1. **Todo bug corrigido ganha um teste** que falha antes da correção. Sem exceção.
2. Nenhum teste depende de tempo real (`OS.get_ticks_msec`), de rede ou de ordem de execução.
3. Todo teste de gameplay usa **seed fixa**. Sem seed, sem determinismo, sem teste.
4. Teste que falha intermitentemente é tratado como bug do teste ou do jogo — **nunca**
   marcado como "flaky" e ignorado.
5. Teste é código: revisado, tipado e sem duplicação grosseira.

## 8. CI

| Gatilho | Roda |
|---|---|
| PR | lint + validação de repo + unit + integration + amostra de gameplay (20 partidas) |
| Merge em `develop` | tudo acima + 200 partidas + benchmarks de território |
| Noturno | 2 000 partidas + benchmarks completos + build de validação |
| Semanal | 5 000 partidas em todos os modos e arenas + relatório de balanceamento |
