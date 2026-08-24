# GSD 09 — Game Feel & Polish

**Status:** ⬜ pendente
**Depende de:** GSD 08
**Branch:** `feature/gsd-09-game-feel`
**Tarefas:** 10 · **Prefixo de ID:** `FEEL`

## Objetivo

> Cumprir o **contrato dos sete canais** para toda ação principal: Gameplay, Animation, VFX,
> SFX, Haptics, Camera e UI Feedback. Uma captura correta e sem impacto é uma implementação
> incompleta — esta é a fase que fecha essa dívida.

## Escopo

**Entra:**
- Partículas e VFX de evento (Seal, Break, Backwash, Surge, power-up, Final Push)
- Reações de câmera: punch, zoom-out em captura grande, micro slow-mo no Mega Seal
- Háptico contextual completo (leve/médio/forte, por evento)
- SFX de gameplay completo, com variações e limite de vozes
- Música adaptativa por camadas, dirigida por território, Surge, ameaça e Final Push
- Popups de bônus, flashes, curvas de animação e transições finais
- Respeito integral a `Reduce shake`, `Reduce flashes` e `Haptics off`
- Pooling de tudo que for instanciado durante a partida

**NÃO entra:**
- Novos assets de arte (é 08, já feito)
- Progressão (é 10)
- Efeitos de Seal cosméticos (é 11)
