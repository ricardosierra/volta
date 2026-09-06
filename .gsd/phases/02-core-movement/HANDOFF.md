# GSD 02 — Core Movement — Handoff

**Concluída em:** — (execução feita em 2026-09-05; **fase NÃO fechada**: MOV-05 reprovado)
**Executada por:** execução autônoma GSD, 7 planos em 4 waves
**Branch / PR:** `feature/gsd-02-core-movement` (sem PR — repositório local, sem remote)

> Esta fase foi **re-executada**. A auditoria de 2026-08-31 encontrou as Fases 2-25 marcadas
> como concluídas com o código escrito mas **desligado** — sem chamador, sem composition root.
> O que segue é o que passou a existir de verdade, não o que já constava como pronto.

## What was implemented

**A peça central:** antes desta fase, o Runner do jogador não era movido por ninguém.
`InputRouter` tinha zero referências no projeto inteiro; `RunnerView` e `GameCamera` também.
`MatchScreen` rodava um loop de simulação próprio, de brinquedo, que ignorava o
`MatchDirector`. Agora existe um caminho único: toque → `InputRouter` → `InputBuffer` →
`MatchDirector.step()` → `Runner` → `RunnerView` → `GameCamera`, montado por `root.gd` como
composition root.

| Plano | Entregue |
|---|---|
| 02-01 | `StatBlock`/`Runner` leem `RunnerBalance` (fim dos literais `300.0`/`180.0`); Bootstrap registra `ConfigService` sob o nome `"config"` |
| 02-02 | FSM ganha `Boot→Loading`, fechando as 11 transições de `docs/architecture/state-machines.md` §2; `ArenaDefinition` ganha `width_cells`/`height_cells`/`cell_size` e `get_pixel_size()`; `open_field.tres` corrigido para 128×128 @ 16 = 2048×2048 |
| 02-03 | `InputBuffer` entra no caminho do `InputRouter`; `mm_to_px()` extraído como `static func`, testável sem `DisplayServer`; os três esquemas (swipe, joystick, relativo) cobertos |
| 02-04 | `RunnerView` estende `InterpolatedVisual` e segue a simulação; `GameCamera.setup()` lê `CameraBalance` real |
| 02-05 | `MatchDirector.configure()` + `player_runner` real + `step()` com input→movimento→contenção; `root.gd` vira composition root completo com `CanvasLayer` para a UI |
| 02-06 | `MatchScreen` para de simular: 588 → 198 linhas; `PauseScreen`/`ResultsScreen` ganham UI real; `SettingsControls` vira `Screen` empilhável ligada ao `InputRouter` ao vivo |
| 02-07 | `latency_test.gd` real (fim do `print` fabricado) + percentil testável headless; este handoff |

## Important decisions

- **`Camera2D` saiu de dentro do `MatchDirector`.** A simulação não pode conhecer nó visual
  (ADR-0001). A câmera passou a ser instanciada pelo composition root e o `MatchDirector`
  expõe só estado. Nenhum ADR novo — é a aplicação do que já estava decidido.
- **A UI ganhou um `CanvasLayer` próprio** em `root.gd`. Sem isso, a `GameCamera` arrastava a
  interface junto com o mundo.
- **Ligação por sinal, não por import.** `RunnerViewSpawner` escuta `runner_spawned(runner)`;
  `gameplay/` continua sem conhecer `presentation/`. É o mesmo padrão que a Fase 26.1 já tinha
  usado para resolver a Regra 7 do quality gate.
- **Nenhum comando `gsd-tools state/roadmap/requirements` foi usado.** Eles corrompem ou são
  no-op neste repositório (histórico nas Fases 26 e 26.1). Toda a metadata foi editada à mão.

## Files created

18 arquivos de teste novos (+ `.uid`):
`test_stat_block.gd`, `test_runner_movement.gd`, `test_state_machine.gd`, `test_game_state.gd`,
`test_arena.gd`, `test_input_router.gd`, `test_swipe_driver.gd`, `test_input_buffer.gd`,
`test_joystick_driver.gd`, `test_relative_driver.gd`, `test_game_camera.gd`,
`test_runner_view_interpolation.gd`, `test_headless_movement.gd`, `test_match_lifecycle.gd`,
`test_pause_freeze.gd`, `test_pause_and_results_screens.gd`, `test_match_screen_wiring.gd`,
`test_latency_test_percentiles.gd`, `test_touch_reaches_input_router.gd`.

Documentos: os 7 `*-SUMMARY.md` da fase e `deferred-items.md`.

## Files modified

`src/runner/stat_block.gd`, `src/runner/runner.gd`, `src/core/bootstrap.gd`,
`src/gameplay/game_state.gd`, `src/arena/arena_definition.gd`, `resources/arenas/open_field.tres`,
`src/input/input_router.gd`, `src/input/drivers/swipe_driver.gd`,
`src/presentation/runner_view.gd`, `src/presentation/runner_view_spawner.gd`,
`src/presentation/camera/game_camera.gd`, `src/gameplay/match_director.gd`, `src/root.gd`,
`src/ui/screens/{match_screen,pause_screen,results_screen,settings_controls,match_hud_builder,match_field_renderer}.gd`,
`tools/dev/latency_test.gd`.

Mais 63 arquivos herdados tocados só para tipagem estática (ver "Known limitations").

## Tests added

127 testes GUT no total ao fim da fase, todos verdes (`./tools/ci/test-client.sh`).
Cobrem: leitura de balance pelo `StatBlock`, giro de 180° pelo `turn_rate`, as 11 transições da
FSM, congelamento em `Paused`, dimensão da arena, enfileiramento/dedup/descarte por idade do
`InputBuffer`, paridade entre os três drivers de input, interpolação da `RunnerView`, clamp da
câmera, determinismo headless de movimento, ciclo de vida da partida, fiação da `MatchScreen`
o cálculo de percentil da latência, e — depois do bug achado no aparelho — a prova ponta a
ponta de que um toque atravessa a pilha de UI e chega ao `_unhandled_input`.

Rodar: `./tools/ci/test-client.sh`.

## Known limitations

- **MOV-05 (latência p95 < 50 ms) está REPROVADO — não pendente.** Medido em Galaxy S23:
  swipe p95 108,0 ms, joystick 109,0 ms, relativo 126,4 ms. O melhor caso é 2,2× a meta. As
  ressalvas todas trabalham a favor da meta (toque sintético via adb subestima; o S23 é tier
  High, e o alvo é Mid), então o vão de 58 ms é real. Ver `docs/performance/device-results.md`.
  **A Fase 2 não fecha por causa disto.**
- **FPS medido só no tier High:** 119-120 estável (teto da tela de 120 Hz) com 1 Runner + 3
  bots. Mid e Low seguem `_pendente_` — não há aparelho desses tiers disponível.
- **Teste de sensação (3 pessoas) não foi feito** — exige gente de fora do projeto jogando.
  Não pode ser sintetizado. `_pendente_`.
- **O aparelho disponível era tier High (Galaxy S23), não Mid** como o `ACCEPTANCE.md` pede.
  Para a reprovação de MOV-05 isso não enfraquece a conclusão (um Mid seria mais lento), mas
  para os números de FPS de A02-12 não substitui o Mid.
- **A moldura de campo desenhada pela `MatchScreen` não coincide com onde os `RunnerView`s
  aparecem** — na captura do aparelho os Runners saem no canto superior esquerdo, fora do
  retângulo. A MatchScreen desenha em coordenadas de tela e os Runners vivem em coordenadas de
  mundo sob a `GameCamera`. Não é regressão desta fase (a moldura passou a ser só moldura no
  Plano 02-06), mas precisa de dono antes de a Fase 3 desenhar território.
- A `MatchScreen` perdeu visuais temporariamente (trilha, captura, feedback de eliminação,
  placar real) porque eles eram desenhados pela simulação de brinquedo que foi removida. Estão
  no backlog com fase de destino, não esquecidos.
- **MOV-06 não fecha:** `GameCamera` tem follow e lookahead reais e testados, mas o **zoom é
  estático** — `setup()` aplica `zoom_base` e nada mais o altera. "Zoom dinâmico" continua por
  fazer.
- **Dívida de tipagem herdada foi zerada nesta fase**, embora fora do escopo original: `lint.sh`
  estava vermelho com 155 violações em 63 arquivos das Fases 3-25. Como `lint.sh` é um dos três
  gates obrigatórios do `CLAUDE.md` §3, toda fase futura fecharia com um check reprovando.
  Corrigido e provado com os três gates.

## Backlog gerado

| ID | O que | Fase de destino |
|---|---|---|
| BL-019 | Trilha e captura de território desenhadas em `MatchScreen` | 03 |
| BL-020 | Feedback visual de eliminação/combate | 04 |
| BL-021 | `ResultsScreen` com placar/colocação reais e PLAY AGAIN sem passar pelo menu | 06 |

## Quality gate

| Item | Estado | Evidência |
|---|---|---|
| `./tools/ci/validate-repo.sh` | ✅ | 10/10 regras, saída colada no `02-07-SUMMARY.md` |
| `./tools/ci/lint.sh` | ✅ | tipagem estática sem violação, docs com H1 |
| `./tools/ci/test-client.sh` | ✅ | 127/127 |
| `./tools/ci/check-project.sh` | ✅ | abre headless sem erro **nem aviso** |
| Simulação sem nó visual | ✅ | grep de `presentation`/`ui` em `gameplay/ runner/ territory/ ai/` vazio |
| Medição em aparelho real | ❌ | **REPROVADO** — p95 108-126 ms contra meta de 50 ms |
| Teste de sensação (3 pessoas) | ⬜ | **aberto** — exige pessoas jogando |

## Next phase prerequisites

Confirmados item a item para a Fase 3 (Territory Engine):

- ✅ `Arena` com dimensão real (`get_pixel_size()` = 2048×2048 em `open_field.tres`) — o solver
  precisa disso para a bounding box do flood fill.
- ✅ `Runner` se movendo de verdade a 60 Hz determinístico, com posição e direção contínuas.
- ✅ `ConfigService` alcançável via `Bootstrap.registry.resolve("config")`.
- ✅ Composition root existe e é o único lugar que conhece os dois lados — é lá que o
  `SealSolver` vai ser ligado.
- ⚠️ `SealSolver`/`SealApplier` continuam **sem chamador** (`match_director.gd` tem só o
  comentário `# 5. resolve seals`). Ligá-los é o trabalho da Fase 3, não uma pendência desta.

## Recommended next command

```text
Execute GSD 03
```
