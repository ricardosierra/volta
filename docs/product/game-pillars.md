# Pilares de design

Cinco pilares. Toda feature precisa servir a pelo menos um e não pode ferir nenhum.
Se uma discussão de design empatar, o pilar de número menor vence.

---

## Pilar 1 — Risco legível

> O jogador sempre sabe o quanto está arriscando, e a recompensa acompanha o risco.

- O Arc aberto é a única fonte real de perigo, e é **visualmente inequívoca**: brilha, pulsa
  e cresce.
- O multiplicador de risco aparece na HUD **enquanto** o arco cresce, não só no resultado.
- Morrer nunca deve parecer aleatório. Se o jogador morreu, ele consegue apontar o erro.

**Fere este pilar:** dano fora de tela, inimigo que aparece de surpresa sem aviso periférico,
power-up que mata sem contra-jogo, câmera que esconde a ameaça.

---

## Pilar 2 — Resposta imediata

> Nenhum toque é ignorado, nenhuma ação fica sem resposta audiovisual.

- Toque → mudança de direção em < 50 ms (buffer de input cobre trocas rápidas).
- Toda ação relevante tem retorno em **quatro canais**: visual, sonoro, háptico e de câmera.
- Nenhuma animação bloqueia o controle. Nunca.

**Fere este pilar:** popup modal no meio da partida, animação de captura que trava o input,
transição de tela sem resposta ao toque.

---

## Pilar 3 — Clareza em movimento

> Em 0,2 s de olhada o jogador identifica: onde estou, o que é meu, o que é ameaça.

- Território próprio, território inimigo, arcos e Runners são distinguíveis por **cor +
  forma + brilho** — nunca só por cor (ver `ui/accessibility.md`).
- HUD mínima: território, posição, Breaks, Surge e tempo (quando aplicável). Nada mais.
- Não existe informação crítica escondida em menu durante a partida.

**Fere este pilar:** partículas que cobrem o campo de jogo, dois temas com cores adjacentes
para jogadores diferentes, HUD com mais de 5 elementos.

---

## Pilar 4 — Expansão como recompensa

> Crescer precisa parecer bom. Cada Seal é um pequeno evento.

- A captura é coreografada: preenchimento animado, partículas na borda, impulso de câmera,
  som que sobe com o tamanho, háptico proporcional.
- A câmera afasta conforme o território cresce: o jogador **vê** o próprio domínio.
- A trilha sonora reage ao percentual dominado.

**Fere este pilar:** captura instantânea sem animação, som único para captura de 1 % e de 20 %,
câmera estática.

---

## Pilar 5 — Justiça

> Vitória vem de decisão, não de carteira nem de sorte de spawn.

- Nenhum item comprável altera velocidade, alcance, defesa, valor de captura ou drop rate.
- Spawns são balanceados por distância mínima e simetria de espaço disponível.
- Bots seguem exatamente as mesmas regras físicas do jogador. Sem velocidade extra, sem
  visão através do mapa fora do raio de percepção definido.

**Fere este pilar:** power-up exclusivo de loja, bot com `speed * 1.3` como "dificuldade",
matchmaking que empurra derrota para vender continue.

---

## Tabela de decisão rápida

| Situação | Pergunta | Pilar |
|---|---|---|
| "Adiciono esse efeito?" | Ele esconde alguma ameaça? | 3 |
| "Aumento a dificuldade?" | Por comportamento ou por número bruto? | 5 |
| "Coloco esse popup?" | Ele interrompe o controle? | 2 |
| "Vendo esse item?" | Ele muda o resultado da partida? | 5 |
| "Corto essa animação por performance?" | O Seal continua parecendo um evento? | 4 |
| "Essa morte foi justa?" | O jogador conseguiria explicar o erro? | 1 |
