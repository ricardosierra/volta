# GSD 02 — Testes

## Unit

| Arquivo | Cobre |
|---|---|
| `test_state_machine.gd` | transições válidas, rejeição das inválidas, sinal emitido |
| `test_game_state.gd` | todas as transições da tabela do documento |
| `test_runner_movement.gd` | taxa de giro, tempo de inversão, velocidade constante, contenção nos limites |
| `test_stat_block.gd` | empilhar, remover, expirar modificadores sem resíduo |
| `test_input_buffer.gd` | enfileiramento, ordem, descarte por idade, comando redundante |
| `test_swipe_driver.gd` | zona morta em mm, direção contínua, manutenção ao soltar |
| `test_simulation_clock.gd` | tick fixo, contagem, `step()` manual |

## Integration

| Arquivo | Cobre |
|---|---|
| `test_match_lifecycle.gd` | Boot → Menu → Loading → Countdown → Playing → Paused → Results |
| `test_pause_freeze.gd` | nada avança durante o pause (posição, contadores, timers) |
| `test_headless_movement.gd` | 600 ticks sem nó visual; determinismo com a mesma seed |

## Performance

| Benchmark | Alvo |
|---|---|
| tick com 1 Runner | < 0,5 ms |
| alocações por tick | 0 |
| FPS na cena de movimento (Mid) | 60 estáveis |
| latência de input p95 | < 50 ms |

## Manual / dispositivo

```text
[ ] os três esquemas de controle funcionam e são trocáveis em runtime
[ ] test drive na tela de settings responde ao vivo
[ ] modo canhoto espelha o joystick
[ ] a câmera não enjoa em 2 minutos de jogo
[ ] o app resiste a background/foreground durante o movimento
[ ] 120 Hz visivelmente mais suave que 60, sem mudar o comportamento
[ ] nenhum toque perdido em swipes rápidos alternados
```

## Critério de saída

Todos verdes **e** o teste de sensação aprovado por pelo menos 2 de 3 pessoas.
