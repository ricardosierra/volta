# Visão de produto

## 1. Pitch

> **VOLTA** é um arcade mobile de conquista territorial em partidas de 90 a 180 segundos.
> Você sai da sua zona segura, desenha um arco luminoso pelo mapa e, ao fechar a volta,
> tudo que ficou dentro vira seu. Enquanto o arco está aberto, você é um alvo.

Uma partida cabe numa fila de banco. Trinta partidas cabem numa noite.

## 2. Por que este jogo existe

O gênero de conquista territorial mobile é enorme e, na prática, mal servido: os títulos
dominantes são tecnicamente frágeis, visualmente datados, cheios de anúncios interstitial
e com bots que se comportam como se estivessem tropeçando pelo mapa. O espaço aberto não é
"o conceito" — é **execução**: responsividade, clareza visual, IA que parece intencional e
uma camada de progressão que respeita o jogador.

VOLTA ataca exatamente isso.

## 3. Público

| Segmento | Descrição | O que espera |
|---|---|---|
| **Primário** | 16–34 anos, joga em sessões de 2–10 min, já jogou `.io` no celular | Entrar rápido, entender sozinho, sensação de progresso a cada partida |
| **Secundário** | Jogador casual de puzzle/arcade | Não morrer nos primeiros 20 s; algo bonito de olhar |
| **Terciário** | Caçador de recorde / competitivo | Leaderboard confiável, controle preciso, sem pay-to-win |

Idioma de lançamento: **inglês** (UI) + **pt-BR**. Estrutura de i18n desde GSD 07.

## 4. Diferencial

1. **Controle que responde.** Turn rate alto, buffer de input, simulação a 60 Hz fixa e
   render até 120 Hz. Nenhum toque perdido — meta de latência toque→movimento < 50 ms.
2. **Bots com intenção legível.** IA por utilidade que escolhe *expandir, interceptar,
   defender ou recuar* por motivos visíveis. Dificuldade sobe por comportamento, nunca por
   `enemySpeed *= 2`.
3. **Identidade visual própria.** Minimalismo neon premium, temas desbloqueáveis, captura com
   resposta audiovisual coreografada (ver `design/game-feel.md`).
4. **Monetização não predatória.** Só cosmético e remover anúncios. Nenhuma vantagem à venda.
5. **Risco como sistema, não como acaso.** O multiplicador de risco transforma "avançar mais"
   numa decisão econômica explícita, mostrada na HUD em tempo real.

## 5. O que VOLTA NÃO é

- Não é um clone: nenhum código, asset, mapa, personagem, UI ou nome de terceiros é reutilizado.
- Não é um battle royale de 100 jogadores.
- Não é um jogo com energia/vidas/timers de espera.
- Não é um jogo onde comprar algo te faz ganhar.

## 6. Métrica-norte

**Partidas por sessão.** Se um jogador médio joga ≥ 4 partidas por sessão, o loop está bom.
Tudo que aumenta esse número sem prejudicar retenção D1 é prioridade.

Métricas de apoio: retenção D1/D7, tempo até primeiro Seal (alvo < 25 s na primeira partida),
% de partidas concluídas (não abandonadas), crash-free sessions ≥ 99,5 %.

## 7. Ordem de prioridade em qualquer decisão (North Star)

```text
1. Fun
2. Responsiveness
3. Clarity
4. Game Feel
5. Performance
6. Visual Quality
7. Retention
8. Monetization
```

Monetização **nunca** ganha de qualquer item acima dela. Este é um critério de review de PR,
não um slogan: um PR que melhora receita e piora clareza é rejeitado.

## 8. Nome e marca

"VOLTA" é **título de trabalho**. Escolhido porque nomeia o verbo do jogo (*dar a volta*,
*fechar a volta*) e carrega a leitura elétrica da direção de arte.

> ⚠️ **Pendência legal (dono: humano, não a equipe técnica):** busca de anterioridade de
> marca para "VOLTA" em software/jogos nos mercados-alvo antes de submeter à loja.
> Rastreado em [`.gsd/RISKS.md`](../../.gsd/RISKS.md) como `RISK-012`. Há colisão conhecida com
> ferramentas de software homônimas fora do setor de jogos; a decisão de manter ou renomear
> deve acontecer **antes de GSD 21**, não depois.

Nome interno de pacote: `com.sierratecnologia.volta`.

## 9. Escopo do primeiro release (`v0.1.0`)

**Dentro:** Classic, Time Attack, Survival, Domination, Endless; 5 arenas; bots com 4
arquétipos e 3 níveis de dificuldade; progressão com XP/ranks/conquistas/desafios diários;
cosméticos (skins, arcos, temas); áudio adaptativo; leaderboard local + remoto; Android + iOS.

**Fora:** multiplayer em tempo real (GSD 17 é arquitetura + protótipo, não release), temporadas,
season pass, eventos ao vivo, clãs, chat.
