# ADR-0006 — Modelo de movimento

## Context

O movimento define a sensação do jogo inteiro e restringe o sistema de território. Duas famílias
são possíveis: **preso ao grid** (4 direções, virada discreta) ou **ângulo livre** (direção
contínua com taxa de giro). A primeira torna a topologia do Arc trivialmente correta; a segunda
é muito melhor no toque, que é o nosso Pilar 2.

## Decision

**Ângulo livre com taxa máxima de giro.** Posição e direção são contínuas (`float`); o Runner
gira em direção ao alvo respeitando um limite angular por segundo. O Arc é **rasterizado** no
grid por traçado *supercover*, garantindo conectividade de 4 vizinhos.

Complementos obrigatórios:
- **buffer de input**: um segundo comando durante uma virada fica na fila e é aplicado em seguida;
- **taxa de giro alta** (540 °/s 🎯) — responsividade acima de realismo;
- movimento amostrado no tick fixo de 60 Hz (ADR-0014);
- Overdrive aumenta velocidade, **não** taxa de giro (é o contra-jogo do power-up).

## Alternatives

| Alternativa | Por que não |
|---|---|
| **4 direções presas ao grid** | Topologia trivial e determinismo perfeito, mas movimento duro; curva fica em degraus, e o toque perde a sensação de deslizar |
| **8 direções** | Meio-termo que herda a rigidez sem ganhar fluidez |
| **Ângulo livre sem limite de giro** | Vira 180° instantâneo: quebra a leitura da ameaça e permite auto-corte constante |
| **Física do engine (`CharacterBody2D` com colisão)** | Introduz não determinismo e custo desnecessário: nossas colisões são consultas ao grid |

## Consequences

**Positivas:** controle fluido e moderno; curvas suaves; combina com todos os três esquemas de
input; a limitação de giro cria decisão real ("não dá para voltar agora").

**Negativas / mitigações:**
- Auto-intersecção acidental fica mais comum → resolvido por ADR-0007 (Backwash em vez de morte).
- A rasterização precisa ser perfeita, senão o flood fill vaza → teste de propriedade obrigatório
  em GSD 03 verificando conectividade 4 para trajetos aleatórios.
- Determinismo exige cuidado com ponto flutuante → tick fixo, ordem de atualização estável e
  nenhuma dependência de `delta` variável na simulação.

## Status

**Accepted** — 2026-08-24.
