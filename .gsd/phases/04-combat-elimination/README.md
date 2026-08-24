# GSD 04 — Combat & Elimination

**Status:** ⬜ pendente
**Depende de:** GSD 03
**Branch:** `feature/gsd-04-combat-elimination`
**Tarefas:** 9 · **Prefixo de ID:** `CMBT`

## Objetivo

> O Arc passa a ser perigoso. Cortar o Arc de alguém elimina; tocar o próprio Arc não mata,
> dá Backwash. A partir daqui existe risco de verdade — e o Pilar 1 precisa ser respeitado em
> cada morte.

## Escopo

**Entra:**
- Colisão Runner × Arc por consulta ao grid (R5.1)
- **Break**: eliminação, crédito, liberação do território (R5.5)
- Morte mútua no mesmo tick (R5.4)
- Repulsão suave em contato Runner × Runner (R5.3)
- **Backwash** completo (R6): auto-colisão, borda e obstáculo
- Squeeze (R4.6) ligado ao fluxo de eliminação
- Respawn com atraso, local válido e invulnerabilidade inicial (R2.4)
- Aviso periférico de ameaça (seta na borda da tela)
- Feedback provisório de morte e de Break (o polimento é da GSD 09)

**NÃO entra:**
- Bots (é 05) — os testes usam Runners controlados por script
- Score e Surge (é 06)
- VFX, SFX e háptico definitivos (é 09)

## Resultado esperado

> Dois Runners na arena (um controlado, outro por script): dá para cortar o Arc do outro,
> morrer, renascer e continuar. Nenhuma morte parece arbitrária.
