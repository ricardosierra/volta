# Regras formais

> Este documento é **normativo**. Se o código discordar dele, o código está errado — ou o
> documento é atualizado no mesmo PR que muda a regra. Constantes numéricas vivem em
> [`../design/balance.md`](../design/balance.md); aqui ficam as regras.

---

## 1. Entidades

| Entidade | Definição |
|---|---|
| **Field** | A arena. Grid lógico de `W × H` células jogáveis + células bloqueadas (obstáculo/void). |
| **Runner** | Entidade controlada por humano ou bot. Posição contínua, direção contínua. |
| **Claim** | Conjunto de células pertencentes a um Runner. |
| **Arc** | Sequência de células marcadas por um Runner enquanto está fora do próprio Claim. |
| **Seal** | Operação que converte a região cercada por Arc + Claim em Claim. |
| **Break** | Eliminação de um Runner causada pelo corte do seu Arc. |
| **Backwash** | Penalidade não-letal: o Arc é descartado e reiniciado na posição atual. |

Cada célula guarda **um** dono (`0` = neutra) e, separadamente, no máximo **um** marcador de
Arc. Célula pode ser simultaneamente Claim de A e Arc de B.

---

## 2. Estados do Runner

```text
Spawn → Safe ⇄ DrawingTrail → Sealing → Safe
                    ↓
                 Backwash → DrawingTrail
                    ↓
                  Broken → Respawning → Spawn        (modos com respawn)
                          ↘ Eliminated               (modos sem respawn)
```

Definições em [`../architecture/state-machines.md`](../architecture/state-machines.md).

**R2.1** — O Runner entra em `DrawingTrail` no primeiro *frame de simulação* em que o centro
dele ocupa uma célula que **não** pertence ao próprio Claim.
**R2.2** — O Runner entra em `Sealing` quando, estando em `DrawingTrail` com Arc de comprimento
≥ 2 células, ocupa uma célula do próprio Claim.
**R2.3** — `Sealing` é resolvido **dentro do mesmo tick**. A animação é apresentação, não estado
de simulação: o jogador recupera o controle imediatamente (Pilar 2).
**R2.4** — Durante `Spawn` o Runner tem invulnerabilidade por um tempo fixo, indicada por anel
pulsante. A invulnerabilidade **cai imediatamente** se o Runner sair do próprio Claim.

---

## 3. Movimento

**R3.1** — Movimento é em **ângulo livre** com taxa máxima de giro (ver [`ADR-0006`](../decisions/ADR-0006-movement-model.md)).
**R3.2** — Velocidade base é **idêntica** para todos os Runners, humanos ou bots (Pilar 5).
Modificadores só vêm de power-ups e de Backwash.
**R3.3** — O Arc é rasterizado no grid por traçado *supercover*, garantindo conectividade de
4 vizinhos. Não existe Arc "furado na diagonal".
**R3.4** — Reentrar numa célula já marcada como Arc próprio no mesmo trajeto conta como
auto-colisão (R6).
**R3.5** — Andar sobre o Claim de um inimigo é permitido e **não** oferece proteção alguma.

---

## 4. Captura (Seal)

**R4.1** — Ao entrar em `Sealing`, o solver considera barreiras: as células do próprio Claim
**mais** as células do próprio Arc.
**R4.2** — A região capturada é o conjunto de células jogáveis que, dentro da bounding box do
Arc expandida em 1, **não** alcançam a borda externa por flood fill de 4 vizinhos atravessando
apenas células não-barreira.
**R4.3** — Toda célula capturada passa a pertencer ao Runner, **inclusive** células que
pertenciam a inimigos (roubo é permitido e é mecânica central).
**R4.4** — As próprias células do Arc viram Claim, e o Arc é limpo.
**R4.5** — Se o Seal engolir células de Arc de um inimigo, aquele inimigo sofre **Backwash**
(não morre). Quem selou recebe o bônus `Cut`.
**R4.6** — Se um Runner ficar com **zero** células de Claim, ele é eliminado por *Squeeze*.
Em modos com respawn, ele renasce com um Claim inicial novo.
**R4.7** — Seals concorrentes no mesmo tick são resolvidos em ordem determinística por
`runner_id` crescente. O segundo solver enxerga o resultado do primeiro. Sem exceção — isso
mantém a simulação reproduzível para testes, replay e servidor autoritativo.
**R4.8** — Um Seal que resultaria em **zero** células capturadas ainda converte o Arc em Claim
e conta como Seal válido (mas não gera pontuação de área nem combo).

---

## 5. Combate

**R5.1** — Um Runner morre (**Break**) quando outro Runner ocupa uma célula marcada como Arc dele.
**R5.2** — O Runner **não** morre pisando no próprio Arc — isso é Backwash (R6).
**R5.3** — Contato corpo a corpo entre Runners, sem Arc envolvido, não mata: aplica repulsão suave.
**R5.4** — Se A entra no Arc de B e B entra no Arc de A no mesmo tick, ambos sofrem Break
(morte mútua). Nenhum dos dois recebe crédito de Break.
**R5.5** — Ao morrer, todo o Claim do Runner morto vira **neutro** (não vai para o matador).
O matador recebe pontos e Surge, não território — território se conquista selando.
**R5.6** — Quem causa o Break recebe: pontos de Break, +1 nível de Surge e um pulso de câmera.
**R5.7** — Um Runner **só** morre por: corte de Arc (R5.1), morte mútua (R5.4), Squeeze (R4.6)
ou perigo específico de arena explicitamente telegrafado (ex.: fenda da arena *Rift*).
Nada mais mata. Essa lista é fechada — qualquer nova causa de morte exige mudança neste documento.

---

## 6. Auto-colisão e borda — Backwash

Decisão registrada em [`ADR-0007`](../decisions/ADR-0007-self-collision-rule.md).

**R6.1** — Tocar o próprio Arc **não mata**: dispara Backwash.
**R6.2** — Colidir com a borda da arena ou com obstáculo sólido enquanto está em
`DrawingTrail` também dispara Backwash (com deflexão do vetor de movimento).
**R6.3** — Backwash aplica, no mesmo tick:
1. o Arc inteiro é apagado (nada é capturado);
2. um **novo** Arc começa na posição atual — o Runner continua vulnerável;
3. o Surge cai a zero;
4. penalidade de velocidade temporária, com feedback visual e sonoro claros.
**R6.4** — Backwash **não** é rota de fuga: como o Arc reinicia imediatamente, o Runner
permanece cortável enquanto estiver fora do Claim.
**R6.5** — Estando em `Safe` (dentro do próprio Claim), colidir com a borda apenas desliza.

---

## 7. Fim de partida

**R7.1** — Uma partida termina por: tempo esgotado, meta de domínio atingida, restar apenas um
Runner vivo, ou o jogador humano ser eliminado em modo sem respawn.
**R7.2** — A classificação é por **percentual de Claim** no instante final; empate é desfeito
por score, depois por maior Seal único, depois por menor tempo total em `DrawingTrail`.
**R7.3** — Nos últimos 30 segundos (**Final Push**) a pontuação de Seal recebe bônus, anunciado
com mudança de cor da HUD, camada extra de música e aviso na tela.
**R7.4** — Abandonar a partida (sair pelo menu) registra derrota, mas **preserva** XP e Sparks
já acumulados. Não punimos o jogador por fechar o app.

---

## 8. Regras de justiça (invioláveis)

**R8.1** — Bots usam exatamente a mesma simulação, mesma velocidade base e mesmas regras de
morte que o jogador.
**R8.2** — Bots não enxergam além do raio de percepção definido pela dificuldade.
**R8.3** — Nenhum item comprável altera qualquer variável desta especificação.
**R8.4** — Spawns respeitam distância mínima entre Runners e espaço livre equivalente.
**R8.5** — A simulação é determinística dado `(seed, sequência de inputs)`. Requisito de teste,
de replay e de futuro servidor autoritativo.

---

## 9. Casos de borda — comportamento obrigatório

| # | Caso | Comportamento |
|---|---|---|
| E01 | Claim dividido em duas regiões desconectadas | Permitido. Ambas contam. Sem "região principal". |
| E02 | Seal cercando o Claim inteiro de um inimigo | Permitido → Squeeze (R4.6). |
| E03 | Arc encostando na borda da arena | Borda é barreira válida: cercar contra a parede funciona. |
| E04 | Arc cruzando Claim inimigo | Permitido; ao selar, aquelas células são roubadas. |
| E05 | Dois Runners entrando no mesmo Arc no mesmo tick | Ambos matam o dono do Arc; crédito vai para o menor `runner_id`. |
| E06 | Seal com Arc de 2 células | Válido; captura tende a zero (R4.8). |
| E07 | Arc atingindo o comprimento máximo | *Overload*: a cauda começa a se desfazer; o jogador é avisado antes. |
| E08 | Runner morre com Seal em andamento no mesmo tick | O Seal resolve primeiro; a morte é aplicada depois (regra de ordem em R4.7). |
| E09 | Todos os bots morrem | Partida continua até o fim do tempo; o jogador pode selar em paz. |
| E10 | Renascer sobre território inimigo | O spawn escolhe o local livre mais próximo que respeita R8.4. |
| E11 | Célula bloqueada dentro da região cercada | Não é capturada; não conta no percentual. |
| E12 | Pause durante `DrawingTrail` | Simulação congela por inteiro. Nada expira em background. |
