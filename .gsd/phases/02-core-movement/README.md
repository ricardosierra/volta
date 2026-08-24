# GSD 02 — Core Movement

**Status:** ⬜ pendente
**Depende de:** GSD 01
**Branch:** `feature/gsd-02-core-movement`
**Tarefas:** 10 · **Prefixo de ID:** `MOVE`

## Objetivo

> O Runner navega pela arena e **é gostoso de mover**. Nada de território ainda — só a
> sensação de controle, que é o alicerce de todo o resto (Pilar 2).

Se o movimento não for excelente aqui, nenhuma quantidade de captura, arte ou som vai salvar
o jogo depois.

## Escopo

**Entra:**
- FSM do jogo (`Boot → Menu → Loading → Countdown → Playing → Paused → Results`), com telas provisórias
- `ArenaDefinition` mínimo (retangular, sem obstáculo) e limites do Field
- `Runner` como entidade de simulação: posição contínua, direção, taxa de giro
- Tick fixo de 60 Hz + interpolação visual manual (ADR-0014)
- Três drivers de input (swipe, joystick, relativo) atrás de `InputRouter`
- Buffer de input
- Câmera: follow com suavização, lookahead, zoom base
- FSM do Runner com os estados que já fazem sentido (`Spawn`, `Safe`, `Eliminated`)
- Medição real de latência toque → mudança de direção

**NÃO entra:**
- Grid, Claim, Arc, Seal (é 03)
- Colisão, morte, respawn (é 04)
- Bots (é 05)
- Arte e UI de verdade (é 07/08)

## Resultado esperado

> Abrir o app no celular, tocar PLAY (botão provisório), e deslizar um círculo pela arena por
> dois minutos sem querer parar. Latência medida abaixo de 50 ms.
