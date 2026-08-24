# Monetização

## Princípio

> Vendemos **identidade e conveniência**. Nunca vantagem.

Se um item altera velocidade, alcance, resistência, valor de captura, frequência de power-up,
qualidade dos bots ou qualquer variável de simulação — **ele não existe na loja**. Ponto.
Este é o Pilar 5 (Justiça) traduzido em regra comercial.

## O que é permitido

| Produto | Tipo | Preço-alvo | Fase |
|---|---|---|---|
| Skins de Runner | cosmético permanente | 1 500–4 000 Sparks ou 80–250 Prisms | GSD 11 |
| Arc Styles (rastro) | cosmético permanente | 1 000–3 000 Sparks ou 60–180 Prisms | GSD 11 |
| Temas de paleta | cosmético permanente | 2 000–5 000 Sparks ou 100–300 Prisms | GSD 11 |
| Seal FX (efeito de captura) | cosmético permanente | 250–400 Prisms | GSD 11 |
| Remove Ads | conveniência, compra única | US$ 2,99 | GSD 25 |
| Pacote de Prisms | moeda hard | US$ 0,99 – 19,99 | GSD 25 |
| Season Pass cosmético | trilha de recompensas só cosmética | US$ 4,99/temporada | GSD 25 (pós-launch) |

**Regra do Season Pass:** a trilha gratuita entrega cosméticos reais, não migalhas. A trilha
paga entrega mais itens, não itens que mudam o jogo.

## O que é proibido

- ❌ Qualquer item que altere a simulação.
- ❌ Continue pago após morte.
- ❌ Loot box / caixa aleatória paga.
- ❌ Energia, vidas, timers que bloqueiam jogar.
- ❌ Anúncio forçado no meio da partida ou em ponto de frustração.
- ❌ Anúncio interstitial antes da primeira partida do jogador novo.
- ❌ Preço dinâmico dirigido por comportamento (o "isso está caro" nunca vira desconto secreto).
- ❌ Dark patterns: botão de compra disfarçado de fechar, contagem regressiva falsa,
  "última chance" recorrente.

## Anúncios (a partir de GSD 25)

Formato único: **rewarded video opt-in**, no máximo 1 a cada 3 partidas, sempre iniciado
pelo jogador, com recompensa clara antes do clique.

| Local | Recompensa | Limite |
|---|---|---|
| Tela de resultado | +50 % Sparks daquela partida | 5/dia |
| Tela de desafios | reroll de 1 desafio diário | 1/dia |

Nunca: interstitial automático, banner na partida, vídeo no boot, vídeo antes do resultado.

## Economia — resumo

Detalhamento completo em [`../design/economy.md`](../design/economy.md).

- **Sparks** (soft): ganhos jogando; média-alvo 250–400 por partida; teto 500.
- **Prisms** (hard): compra ou conquistas de marco; nunca necessários para progredir.
- Um jogador que nunca gasta dinheiro deve conseguir desbloquear **qualquer** cosmético
  não-exclusivo com jogo consistente. Alvo: ~1 item médio a cada 8–12 partidas no início.

## KPIs e limites éticos

| KPI | Alvo | Limite ético |
|---|---|---|
| Conversão para pagante | 2–4 % | não perseguir via pressão |
| ARPDAU | ver `product/analytics-plan.md` | nunca acima de retenção |
| % receita de baleias (top 1 %) | < 40 % | se passar disso, revisar preços altos |
| Reembolso / arrependimento | < 1 % | qualquer pico dispara auditoria de UX de compra |

## Transparência

- Todo preço mostrado em moeda local antes da confirmação.
- Toda compra dá recibo na tela e no perfil.
- Nada de "moeda intermediária de moeda" (Prisms compram itens diretamente — não existe
  terceira camada para ofuscar valor).
