# Analytics Validation Report

> **Status: NÃO EXECUTADO.** Revisado em 2026-08-31 durante a auditoria das fases 10–25.
> A versão anterior afirmava um pipeline "fully functional and compliant". A verificação no
> código mostra que o pipeline não está ligado a nada.

## Por que este relatório foi reescrito

A versão anterior declarava fluxo de eventos conferido com proxy, envio em lotes de 10 para
`/telemetry`, captura de FPS/memória sem travar, e descarte de eventos ao desligar a
privacidade. A verificação por busca no repositório contradiz cada ponto:

- `AnalyticsBridge`, `CrashReporter` e `PerformanceSampler` **não são referenciados em lugar
  nenhum** fora dos próprios arquivos. Nenhum é registrado em `apps/mobile/src/core/bootstrap.gd`
  (que instancia apenas `quality`, `haptics`, `vfx`, `wallet`, `catalog`, `profile_repo`) nem
  aparece em `[autoload]` de `apps/mobile/project.godot` (só `Bootstrap` e `Log`).
- O sinal `match_ended` é emitido em `apps/mobile/src/gameplay/match_director.gd:126` e
  **nenhum ouvinte está conectado**. `analytics_bridge.gd:12` define `on_match_ended()`, mas
  nada liga o sinal a esse método.
- Sem instância viva, não existe buffer, não existe lote de 10, não existe envio a `/telemetry`.
- O endpoint `/telemetry` estaria em `services/api/`, que não é um projeto Laravel executável
  (sem `composer.json`, sem `artisan`).

## O que está de fato verificado

| Item | Estado | Evidência |
|---|---|---|
| Classes de analytics existem | Sim | `apps/mobile/src/platform/analytics/`, `gameplay/analytics_bridge.gd` |
| Alguma delas é instanciada | **Não** | zero referências fora do próprio arquivo |
| Eventos chegam ao backend | **Não** | sem instância e sem backend executável |
| Amostragem de performance roda | **Não** | `PerformanceSampler` nunca instanciado |
| Opt-out de privacidade funciona | **Não verificado** | UI de privacidade sem implementação |

## Risco de conformidade

`docs/legal/privacy-policy.md` promete ao jogador um controle de opt-out. Enquanto esse
controle não existir de fato, a política afirma ao usuário algo que o aplicativo não entrega.
Isto precisa ser resolvido **antes** de qualquer publicação, e é pré-requisito da Fase 30
(Game Stats), que pretende reusar este pipeline.

## O que falta para validar de verdade

1. Registrar o pipeline de analytics em `bootstrap.gd` e conectar `match_ended`.
2. Implementar de fato o opt-out e provar por teste que ele descarta o buffer.
3. Tornar `services/api/` executável para haver um `/telemetry` real.
4. Só então medir lote, latência e impacto de quadro — com números reproduzíveis.
