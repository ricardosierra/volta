# GSD 06 — Complete Match Loop 🏁 MVP

**Status:** ⬜ pendente
**Depende de:** GSD 05
**Branch:** `feature/gsd-06-match-loop`
**Tarefas:** 10 · **Prefixo de ID:** `LOOP`

## Objetivo

> Fechar o ciclo: countdown → partida → score → fim → resultado → jogar de novo em um toque.
> **Ao fim desta fase existe um jogo completo** — feio, mudo, sem progressão, mas jogável do
> início ao fim e divertido.

## Escopo

**Entra:**
- Countdown de 3 s (com input já sendo lido)
- Sistema de score completo, com a fórmula de `docs/design/scoring.md`
- Surge: níveis, janelas, decaimento, zeragem
- Os 9 bônus nomeados
- Final Push nos últimos 30 s
- Condições de fim de partida e ranking com desempate (R7.2)
- Tela de resultado com contagem animada e **PLAY AGAIN dominante**
- Restart em um toque, sem passar pelo menu
- `LocalLeaderboardRepository` (MOCK-001) e recordes pessoais
- `AnalyticsService` + `NoopAnalytics` (MOCK-002) com os eventos de partida
- HUD funcional mínima (território, posição, tempo, risco, pause)

**NÃO entra:**
- Design system e telas bonitas (é 07)
- Arte final (é 08)
- VFX/SFX/háptico finais (é 09)
- XP, ranks, conquistas (é 10)
- Outros modos (é 12)

## Resultado esperado — critérios do MVP

```text
[ ] o jogo inicia
[ ] o Runner se move
[ ] o Arc funciona
[ ] o Claim fecha
[ ] a área é conquistada
[ ] inimigos existem
[ ] Arcs podem ser atacados
[ ] Runners podem morrer
[ ] bots jogam
[ ] a partida termina
[ ] score existe
[ ] resultado existe
[ ] restart existe
[ ] UI consistente (dentro do provisório)
[ ] 60 FPS estáveis no aparelho-alvo
[ ] nenhum bug crítico
```
