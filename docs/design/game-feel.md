# Game feel

> **Regra do projeto:** uma captura matematicamente correta e visualmente sem impacto é uma
> implementação **incompleta**. Toda interação principal precisa responder em sete canais.

## O contrato dos sete canais

Toda ação relevante declara o que faz em cada canal. Sem isso, a tarefa não passa no gate.

```text
Gameplay · Animation · VFX · SFX · Haptics · Camera · UI Feedback
```

---

## Tabela de resposta por ação

| Ação | Gameplay | Animation | VFX | SFX | Haptics | Camera | UI |
|---|---|---|---|---|---|---|---|
| **Mudança de direção** | direção alvo muda | leve inclinação do Runner | faísca curta no rastro | tick sutil (opcional) | mínimo (opt-in) | lookahead reposiciona | — |
| **Sair do Claim** | entra em `DrawingTrail` | squash rápido | flash na borda cruzada | *whoosh* grave | leve | zoom out 2 % | risco aparece na HUD |
| **Arc crescendo** | risco sobe | — | brilho e pulso proporcionais | camada de música sobe | — | — | multiplicador conta ao vivo |
| **Seal pequeno** (< 2 %) | território += | pop do Runner | preenchimento radial rápido | acorde curto | leve | punch 3 % | `+X%` sobe e some |
| **Seal médio** (2–8 %) | idem | pop maior | preenchimento + faíscas na borda | acorde + swell | médio | punch 5 % + zoom out | `+X%` + nome do bônus |
| **Mega Seal** (> 8 %) | idem | stretch dramático | onda de choque na borda + partículas | acorde cheio + risada de sintetizador | forte | punch 7 % + slow-mo 0,12 s | banner central |
| **Break (você mata)** | +pontos, +Surge | Runner inimigo estilhaça | explosão geométrica do Arc | impacto seco + reverb | forte | punch 6 % | `BREAK!` + streak |
| **Morrer** | fim / respawn | dissolução do Runner | Arc se desfaz célula a célula | corte súbito da música | duplo forte | zoom out lento | tela escurece nas bordas |
| **Backwash** | Arc reinicia | tremor do Runner | Arc "vaza" e some | som de curto-circuito | médio | shake 2 % | `BACKWASH` em âmbar |
| **Power-up** | efeito aplicado | orbe é sugado | aura por tipo | jingle por tipo | leve | — | ícone com timer radial |
| **Surge sobe** | multiplicador += | — | intensidade da aura += | camada nova entra | tick por nível | — | medidor de Surge pulsa |
| **Final Push** | pontos ×1,25 | — | vinheta quente | música muda de camada | duplo médio | zoom out 4 % | HUD muda de cor |
| **Vitória** | — | Runner comemora | fogos geométricos | fanfarra curta | padrão longo | zoom out total | resultado entra em cascata |

---

## Princípios inegociáveis

1. **Nada bloqueia o controle.** Nem captura, nem morte, nem popup, nem transição. Slow-mo
   máximo é curtíssimo e o input continua sendo lido.
2. **Feedback proporcional.** Capturar 1 % e capturar 20 % não podem soar nem tremer igual.
   Toda intensidade é função contínua do tamanho do evento.
3. **Nada de shake gratuito.** Screen shake só em Break e Mega Seal, sempre escalado por
   `Settings > Reduce shake`, que pode zerar por completo.
4. **Legibilidade acima de espetáculo.** Nenhum efeito pode cobrir o Field a ponto de esconder
   um Arc inimigo. Em caso de conflito, o efeito perde (Pilar 3).
5. **Áudio é informação.** O jogador precisa saber que morreu, capturou ou foi ameaçado
   **sem** olhar a HUD.
6. **Silêncio existe.** Nem toda ação pede som. Excesso de SFX vira ruído e mata o impacto do Seal.

---

## Curvas e tempos

| Momento | Duração 🎯 | Easing |
|---|---|---|
| Preenchimento do Seal | 0,28 s | `ease_out_cubic` a partir do ponto de fechamento |
| Punch de câmera | 0,12–0,18 s | `ease_out_back` |
| Popup de bônus | 0,9 s (0,12 entra · 0,5 fica · 0,28 sai) | `ease_out_back` / `ease_in_quad` |
| Dissolução na morte | 0,45 s | `ease_in_expo` |
| Transição de tela | 0,25 s | `ease_in_out_quad` |
| Aparecimento de HUD | 0,18 s escalonado 40 ms | `ease_out_quad` |

Tempo de transição **nunca** passa de 0,3 s. Menu lento é menu que o jogador aprende a odiar.

---

## Háptico

| Evento | Padrão | Intensidade |
|---|---|---|
| Botão de UI | pulso único curtíssimo | mínima |
| Seal pequeno | pulso único | leve |
| Seal grande | pulso duplo ascendente | média |
| Break (você mata) | pulso forte único | forte |
| Sua morte | dois pulsos fortes | forte |
| Surge sobe de nível | tick curto | leve |
| Aviso de Overload | três ticks rápidos | média |

`Settings > Haptics` tem: Off · Light · Full. Padrão **Full** no Android, **Full** no iOS
(via `Core Haptics` quando disponível, com fallback). Nada de vibração contínua — economiza
bateria e não vira irritação.

---

## Como isso é verificado

- Toda tarefa que toca uma ação da tabela precisa marcar os sete canais no seu
  `Definition of Done`.
- GSD 09 faz uma passada dedicada e grava vídeo lado a lado (antes/depois) de cada ação.
- Teste de acessibilidade: com `Reduce shake`, `Reduce flashes` e `Haptics Off` ligados, o
  jogo continua **jogável e legível** — os canais restantes precisam bastar.
