# 02-07 Phase Closeout — Summary

**Plano:** `02-07-phase-closeout-PLAN.md`
**Executado:** 2026-09-05
**Tasks:** 3/3
**Resultado:** fase executada por inteiro; **fase NÃO fechada** — MOV-05 reprovado com medição real

## Task 1 — `latency_test.gd` real

`generate_report()` imprimia `"Latency P50: 32ms"` **fixo** e `_process()` era `pass` — o caso
exato que a Regra de Ouro Anti-Burla proíbe. Substituído por instrumentação de três estágios
(timestamp do `InputEvent` → tick em que `desired_direction` mudou → primeiro frame com mudança
visível de rotação). `percentile()` é estática e pura, com 5 testes headless; array vazio
devolve `-1.0`, nunca um número inventado.

**Desvio do texto do plano, deliberado.** O plano mandava fechar a amostra quando a view
chegasse a 2° da direção *desejada*. Isso mede a **duração do giro**, não a latência: a 540°/s
(`balance.md`), 90° levam 167 ms e 180° levam 333 ms — `p95 < 50 ms` seria impossível por
construção, e o número mudaria sozinho se o `turn_rate` mudasse, sem nenhuma piora de
responsividade. `docs/gameplay/controls.md` é autoritativo (CLAUDE.md §2) e define a meta como
*"latência toque → mudança de direção < 50 ms"*. A amostra passou a fechar na primeira mudança
acima de 0,5°. Efeito medido: p50 141,7 → 75,1 ms.

## Task 2 — Checkpoint no aparelho (feito, não deferido)

Executado em **Galaxy S23 (SM-S911B, Android 16)** via `adb`, com toque sintético.

### Bug crítico encontrado

Com **124 testes headless verdes**, o jogo estava **sem controle nenhum no aparelho**.
Diagnóstico no dispositivo: `unhandled=0`, `runner=ok`, `desired_direction` travada em `(0,-1)`.

Causa: `ScreenStack` estende `Control` em full rect e nunca setava `mouse_filter`, ficando com o
`MOUSE_FILTER_STOP` padrão — consumia todo toque antes de virar `unhandled`. `root.gd` tinha o
mesmo problema; `MatchScreen` só setava `IGNORE` dentro de `on_pushed()`, tarde demais.

Corrigido em `f0be3b2`. Depois: `unhandled=236+`, direção variando, amostras registrando.
Regressão em `test_touch_reaches_input_router.gd`, que empurra o evento por
`get_tree().root.push_input()` — a suíte antiga chamava o `InputRouter` diretamente, que é
exatamente por que 124 testes não pegaram isto.

### Números (cada esquema com o app reiniciado, 130 disparos, flick de 16 ms)

| Esquema | Amostras | p50 | p95 | Meta | Passa? |
|---|---|---|---|---|---|
| Swipe | 129 | 75,1 ms | 108,0 ms | < 50 ms | ❌ |
| Joystick | 129 | 75,0 ms | 109,0 ms | < 50 ms | ❌ |
| Relativo | 99 | 91,9 ms | 126,4 ms | < 50 ms | ❌ |

FPS: **119-120 estável** (teto da tela de 120 Hz), 1 Runner + 3 bots.

**Ressalvas, todas a favor da meta:** o toque via `adb` entra pelo `InputManager` e não passa
pelo digitalizador, subestimando em ~5-15 ms; e o S23 é tier **High**, enquanto o alvo do
`ACCEPTANCE.md` é **Mid** (mais lento). Descontar isso não fecha um vão de 58 ms.

**Conclusão: MOV-05 reprovado, não pendente.** É medição feita, com resultado negativo.

Pendentes de verdade: FPS em Mid e Low (não há aparelho desses tiers) e o teste de sensação com
3 pessoas (não pode ser sintetizado).

## Task 3 — Fechamento formal

`device-results.md` ganhou a seção da Fase 2 com os números reais, o método e as ressalvas.
`HANDOFF.md` preenchido. `QUALITY_GATES.md` linha 02 = 🟡 parcial. `REQUIREMENTS.md`:
MOV-01/02/03/04/07 `[x]`; **MOV-05 `[ ]` reprovado**; **MOV-06 `[ ]`** — ao conferir antes de
marcar, `GameCamera` tem follow e lookahead reais mas o **zoom é estático**, e o requisito pede
"zoom dinâmico". `ROADMAP.md` não marca a Fase 2 completa.

### Saída real das checagens

```text
=== validate-repo.sh ===
✅ validate-repo: tudo certo.        (10/10 regras)

=== lint.sh ===
OK: tipagem estática — nenhuma violação encontrada
OK: todos os docs começam com título H1
✅ lint: tudo certo.

=== test-client.sh ===
Scripts              37
Tests               127
Passing Tests       127
Asserts             277
---- All tests passed! ----

=== check-project.sh ===
✅ check-project: apps/mobile abre headless sem erro nem warning.
```

## Trabalho fora do escopo do plano, feito por bloquear tudo

`lint.sh` estava **vermelho** com 155 violações de tipagem em 63 arquivos herdados das Fases
3-25. Como é um dos três gates obrigatórios do `CLAUDE.md` §3, toda fase futura fecharia com um
check reprovando. Zerado (`67d9ed6`, `cd56d26`). Onde `:=` não infere, tipo explícito: `get_meta()`
devolve Variant; `pop_front()`/`back()` em `Array` devolvem Variant; `var x := null` precisa da
classe. `VfxPool._inactive`/`_active` viraram `Array[Node]`, que era a raiz do problema lá.

Também: `test_build.gd` comparava a versão com o literal `"0.1.0"` congelado enquanto
`project.godot` já estava em `0.1.2` desde o release F-Droid — passou a comparar com o
`ProjectSettings` (`c94f7fd`).

## O que a Fase 3 herda

Runner se movendo de verdade a 60 Hz, Arena com dimensão real (2048×2048), `ConfigService`
alcançável, composition root montado — e, agora, **input que de fato chega ao jogo**.
`SealSolver`/`SealApplier` continuam sem chamador: é o trabalho da Fase 3.

Atenção: a moldura de campo da `MatchScreen` não coincide com onde os `RunnerView`s aparecem
(tela vs. mundo sob a `GameCamera`). Precisa de dono antes de desenhar território.
