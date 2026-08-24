# Power-ups

> **Regra fundadora:** nenhum power-up pode existir se não tiver contra-jogo. Se a única
> resposta possível é "azar", ele não entra. E nada disso é vendável (Pilar 5).

Power-ups aparecem no Field como orbes coletáveis. Só existem nos modos que os habilitam
(ver [`game-modes.md`](game-modes.md)). São implementados em **GSD 14**.

## Regras gerais

1. **Duração curta** — nenhum passa de poucos segundos. O jogo não vira "quem pegou o item".
2. **Visual inequívoco** — quem está com o efeito é identificável de longe, por forma e cor,
   inclusive pelo adversário (Pilar 3).
3. **Aviso de spawn** — o orbe pisca antes de existir; ninguém é surpreendido.
4. **Nunca em cima de ninguém** — spawn respeita distância mínima de todos os Runners.
5. **Um por vez** — pegar um novo substitui o ativo (sem empilhamento).
6. **Nunca letal por si só** — power-up não mata; ele muda a posição do risco.

---

## Os seis

### 1. Bulwark *(Shield)*
Absorve **um** Break. O anel do Runner ganha casca visível; ao absorver, quebra com estrondo.

- **Contra-jogo:** ataque duas vezes; o escudo é consumido e some.
- **Risco de design:** pode virar passe livre para arcos suicidas → duração curta e o escudo
  **não** protege contra Squeeze (R4.6).

### 2. Overdrive *(Speed Burst)*
Aumenta a velocidade por poucos segundos. Rastro alongado, som ascendente.

- **Contra-jogo:** a taxa de giro **não** aumenta — o Runner fica rápido e desengonçado.
  Corte a rota dele, não persiga.

### 3. Arc Guard *(Trail Shield)*
Torna as células mais antigas do Arc temporariamente incortáveis (brilham em branco).
A ponta do Arc, perto do Runner, continua vulnerável.

- **Contra-jogo:** ataque a **ponta**. O efeito ensina uma habilidade real: cortar perto de quem desenha.

### 4. Pulse *(Radar)*
Revela por alguns segundos, na borda da tela, a direção de todos os Runners e de todos os Arcs
abertos.

- **Contra-jogo:** informação é simétrica — quem está sendo revelado vê o pulso acontecer e sabe
  que foi visto.

### 5. Amplify *(Capture Boost)*
O próximo Seal vale mais pontos (não mais área). O Runner brilha em dourado.

- **Contra-jogo:** ele **precisa** fechar para aproveitar → vira alvo previsível.
- **Nota de design:** amplifica *pontos*, nunca *território*, para não distorcer o mapa.

### 6. Drag Field *(Slow Field)*
Deixa uma área que reduz a velocidade de quem entrar — inclusive de quem soltou.

- **Contra-jogo:** é visível, estático e contornável. Serve para negar rota, não para pegar alguém.

---

## Balanceamento

Todos os valores (duração, raio, intensidade, taxa de spawn, peso por modo) vivem em
`packages/shared/config/powerups/*.tres` e estão listados em
[`../design/balance.md`](../design/balance.md). Ajuste é dado, não código.

| Métrica de saúde | Alvo |
|---|---|
| % de partidas decididas por power-up | < 15 % |
| Winrate de quem pegou o primeiro orbe | 50 % ± 8 pp |
| Tempo médio com algum efeito ativo | < 20 % da partida |

Se qualquer uma estourar, o power-up é enfraquecido — nunca removido sem antes tentar ajustar,
e nunca vendido para compensar.

---

## Contrato de implementação

```gdscript
class_name PowerUpEffect
func on_apply(runner: RunnerContext) -> void
func on_tick(runner: RunnerContext, delta: float) -> void
func on_expire(runner: RunnerContext) -> void
func describe() -> PowerUpDescriptor   # ícone, cor, nome, duração — para HUD e VFX
```

- O efeito **nunca** escreve direto em campos do Runner: ele empilha modificadores num
  `StatBlock`, que é resolvido num único ponto. Isso mantém remoção e expiração triviais.
- Todo efeito é reversível e idempotente na expiração (testado em GSD 14).
- Todo efeito declara seu VFX, SFX e háptico no descritor — sem isso não passa no gate de
  game feel (ver [`../design/game-feel.md`](../design/game-feel.md)).
