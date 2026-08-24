# Score, risco e Surge

> Fórmula normativa. Implementada em `gameplay/score/` e coberta por testes unitários
> (GSD 06). Constantes ajustáveis vivem em `packages/shared/config/score/*.tres` e estão
> tabeladas em [`balance.md`](balance.md).

---

## 1. Fórmula

```text
score = round(
    Σ seal_points
  + Σ break_points
  + survival_points
  + final_territory_points
  + largest_seal_bonus
  + placement_bonus
) × victory_multiplier
```

### 1.1 Pontos de Seal (por captura)

```text
seal_points = cells_sealed × CELL_VALUE × risk_multiplier × surge_multiplier × push_multiplier
```

| Termo | Definição |
|---|---|
| `cells_sealed` | células efetivamente convertidas (inclui roubadas, exclui bloqueadas) |
| `CELL_VALUE` | valor base por célula |
| `risk_multiplier` | ver 1.2 |
| `surge_multiplier` | ver 2 |
| `push_multiplier` | bônus do Final Push nos últimos 30 s (1,0 fora dele) |

Roubar célula de inimigo vale **mais** que capturar neutra: cada célula roubada recebe um
multiplicador extra. É a regra que faz o meio da partida ser sobre disputa, não sobre correr
para o canto vazio.

### 1.2 Multiplicador de risco

```text
risk_multiplier = 1 + clamp(arc_cells / RISK_DIVISOR, 0, RISK_CAP)
```

Cresce com o comprimento do Arc **no momento do Seal**, saturando num teto. É o número que a
HUD mostra em tempo real enquanto o jogador desenha — a tradução visível do Pilar 1.

### 1.3 Break

```text
break_points = BREAK_BASE + BREAK_STREAK_STEP × min(consecutive_breaks, BREAK_STREAK_CAP)
```

O contador de sequência zera quando o jogador morre ou após uma janela sem Breaks.

### 1.4 Demais termos

| Termo | Fórmula |
|---|---|
| `survival_points` | segundos vivo × valor por segundo |
| `final_territory_points` | `claim_pct_final × TERRITORY_WEIGHT` |
| `largest_seal_bonus` | `maior_seal_pct × LARGEST_SEAL_WEIGHT` |
| `placement_bonus` | tabela por colocação (1º, 2º, 3º, demais) |
| `victory_multiplier` | aplicado só ao 1º lugar |

---

## 2. Surge — o sistema de combo

Surge é o multiplicador de ritmo. Ele recompensa **encadear**, não acumular.

```text
surge_multiplier = 1 + SURGE_STEP × min(surge_level, SURGE_MAX_LEVEL)
```

**Sobe:** +1 nível a cada Seal dentro da janela de encadeamento desde o Seal anterior;
+1 a cada Break dentro da janela de Break.
**Cai:** −1 nível a cada intervalo sem Seal nem Break.
**Zera:** ao morrer ou sofrer Backwash.

| Nível | Nome | Feedback |
|---|---|---|
| 1 | Spark | brilho leve no Runner, tick sonoro agudo |
| 2 | Flow | rastro mais denso, camada de música entra |
| 3 | Charge | partículas orbitais, HUD ganha borda pulsante |
| 4 | Storm | distorção sutil ao redor do Runner, batida dobra |
| 5 | Overload | tela ganha vinheta colorida, som saturado |
| 6 | Singularity | teto: aura completa, música em camada máxima, háptico de manutenção |

---

## 3. Bônus nomeados

Aparecem como popup na tela, empilhados verticalmente, com som próprio:

| Bônus | Condição |
|---|---|
| **Double Seal** | 2 Seals dentro da janela de encadeamento |
| **Triple Seal** | 3 Seals encadeados |
| **Claim Streak** | 5 Seals sem morrer |
| **Break Streak** | 2+ Breaks encadeados |
| **Risk Bonus** | Seal com multiplicador de risco acima do limiar alto |
| **Close Call** | Seal com inimigo a poucas células do Arc no último segundo |
| **Mega Seal** | um único Seal acima do limiar de área grande |
| **Cut** | seu Seal engoliu o Arc de um inimigo (R4.5) |
| **Squeeze** | você zerou o território de um inimigo (R4.6) |

Cada bônus tem valor fixo em pontos **e** um efeito de Surge. Nenhum é secreto: todos aparecem
listados em `Profile > Records`, para o jogador saber que existem e caçá-los.

---

## 4. Score fora da partida

| Contexto | Valor |
|---|---|
| XP | derivado do score, mais bônus por Break e por vitória |
| Sparks | derivado do score, com teto por partida (evita farm degenerado) |
| Leaderboard Classic | `score` |
| Leaderboard Time Attack | `claim_pct_final` |
| Leaderboard Survival | `survival_time` |
| Leaderboard Endless | `score` acumulado |

Fórmulas de XP e Sparks em [`progression.md`](progression.md) e [`economy.md`](economy.md).

---

## 5. Invariantes testáveis (GSD 06)

- `score ≥ 0` sempre.
- Score é **determinístico** para a mesma sequência de eventos.
- Nenhum termo pode explodir: todo multiplicador tem teto documentado.
- Um Seal de 0 células gera 0 pontos de área, mas não quebra o Surge.
- A soma dos scores de todos os Runners não é usada para nada — ranking é por território (R7.2).
