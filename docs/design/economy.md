# Economia

Duas moedas. Nenhuma delas compra vantagem.

| Moeda | Símbolo | Origem | Destino |
|---|---|---|---|
| **Sparks** | ✦ | jogar (score), desafios, conquistas, rank | maioria dos cosméticos |
| **Prisms** | ◈ | compra com dinheiro real, conquistas de marco, season pass | cosméticos premium, efeitos de Seal |

## Fontes (torneiras)

| Fonte | Valor 🎯 | Frequência |
|---|---|---|
| Partida | `clamp(floor(score/60), 0, 500)` ✦ | toda partida |
| Bônus de 1ª vitória do dia | 250 ✦ | 1×/dia |
| Desafio diário | 150–400 ✦ | 3/dia |
| Desafio semanal | 800–1 500 ✦ | 3/semana |
| Subir de rank | 200 ✦ + a cada 5 níveis um cosmético | contínuo |
| Conquista | 100–2 000 ✦ | finito |
| Conquista de marco | 10–50 ◈ | finito |
| Rewarded ad (GSD 25) | +50 % dos ✦ da partida | máx. 5/dia |

**Renda média projetada** 🎯: ~1 200 ✦/dia para quem joga 20 minutos. Uma skin média (2 500 ✦)
sai em ~2 dias de jogo casual, ou ~8–12 partidas de jogo forte.

## Drenos

| Item | Preço 🎯 |
|---|---|
| Skin comum | 1 500 ✦ |
| Skin rara | 2 500 ✦ |
| Skin épica | 4 000 ✦ ou 250 ◈ |
| Arc Style | 1 000–3 000 ✦ |
| Tema de paleta | 2 000–5 000 ✦ |
| Seal FX | 250–400 ◈ (só premium) |
| Reroll extra de desafio | 100 ✦ (máx. 2/dia) |

Não existe dreno obrigatório. Um jogador pode nunca gastar e nunca ser penalizado por isso.

## Regras de saúde econômica

1. **Sem inflação escondida:** preços não sobem com o nível do jogador.
2. **Sem terceira moeda.** Prisms compram itens diretamente. Nenhuma camada de ofuscação.
3. **Sem item consumível que afeta partida.** Consumível só existe para conveniência de meta
   (ex.: reroll de desafio).
4. **Teto de ✦ por partida** evita farm degenerado em Endless.
5. **Prisms nunca são exigidos** para completar coleções não-premium.
6. **Nada expira.** Cosmético comprado é permanente, inclusive de temporada passada.

## Métricas de monitoramento (GSD 18+)

| Métrica | Alvo 🎯 | Ação se estourar |
|---|---|---|
| ✦ ganhos/dia por jogador ativo | 800–1 600 | ajustar divisor de score |
| Saldo médio de ✦ após 30 dias | < 10 000 | preços ou torneiras desbalanceados |
| Tempo até o 1º cosmético | < 3 dias | reduzir preço de entrada |
| % de jogadores com ≥ 1 cosmético | > 70 % em D7 | revisar torneiras |
| Conversão para pagante | 2–4 % | **nunca** corrigir com pressão ou paywall |

## Simulação

`tools/dev/economy_sim.php` (GSD 10) roda perfis sintéticos — casual, médio, hardcore — por
30 dias e reporta saldo, itens desbloqueados e tempo até o primeiro desbloqueio. Rodar antes
de qualquer mudança de preço.
