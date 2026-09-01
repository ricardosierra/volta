# Auditoria das fases 2 a 25 — índice

**Data:** 2026-08-31
**Motivo:** antes de executar as fases 27–38 (integração Google Play Games), verificar se a
fundação sobre a qual elas seriam construídas existe de fato.

## Como a auditoria foi feita

Teste de **alcançabilidade**, não de existência de arquivo: para cada classe entregue por uma
fase, verificar se algo fora do próprio arquivo a referencia, se é registrada em
`apps/mobile/src/core/bootstrap.gd`, se está em `[autoload]`, ou se é citada por uma cena.
Um arquivo bem escrito que ninguém instancia não é funcionalidade entregue.

O gatilho foi a constatação de que as fases 10–25 estavam marcadas concluídas sem nenhum
`SUMMARY.md` em disco, apesar de todas terem `VERIFICATION.md` com `status: passed`.

## Relatórios

| Arquivo | Fases | Veredito |
|---|---|---|
| [`../AUDIT-PHASES-10-25.md`](../AUDIT-PHASES-10-25.md) | 10, 15, 16, 18, 21 | 5 de 5 não confiáveis |
| [`AUDIT-11-14.md`](AUDIT-11-14.md) | 11, 12, 13, 14 | 13 em boa parte real; 11 parcial; 12 e 14 não confiáveis |
| [`AUDIT-17-20.md`](AUDIT-17-20.md) | 17, 19, 20 | 3 de 3 não confiáveis, com números fabricados |
| [`AUDIT-22-25.md`](AUDIT-22-25.md) | 22, 23, 24, 25 | 4 de 4 não confiáveis |

As fases 2–9 não receberam relatório próprio; foram verificadas por amostragem de
alcançabilidade durante a consolidação (ver `.planning/STATE.md`, seção da auditoria).

## Os cinco fatos que sustentam tudo

1. `apps/mobile/src/core/bootstrap.gd` — a raiz de injeção — registra **6 de 32 serviços**:
   `quality`, `haptics`, `vfx`, `wallet`, `catalog`, `profile_repo`. Só há dois autoloads
   (`Bootstrap`, `Log`) em `apps/mobile/project.godot`.
2. O sinal `match_ended` (`apps/mobile/src/gameplay/match_director.gd:126`) é emitido e
   **nenhum ouvinte está conectado**. Os handlers `progression_bridge.gd:9` e
   `analytics_bridge.gd:12` existem, mas nada os liga.
3. `SealSolver` e `SealApplier` — a captura de território, mecânica central do jogo — têm
   **zero chamadores**. `match_director.gd:25` contém apenas o comentário
   `# 5. resolve seals (by runner_id)`.
4. `.github/workflows/godot-ci.yml:15` roda `apps/mobile/tools/dev/simulate.gd`, que imprime
   `"All 2500 simulations passed"` sem instanciar nenhuma partida — o próprio comentário do
   arquivo admite. **A CI está verde por construção.**
5. `tools/ci/build_android.sh:27-29` — o ramo `release` é `exit 1`. Não existe build de
   release, logo nada foi publicado.

## O que é sólido

- **Fase 1** — projeto, config em dados, save atômico, log, EventBus, verificadores e CI. Real,
  com 11 SUMMARYs e testes.
- **Fase 13** — a abstração de arena (`ArenaDefinition`, `Arena`) está genuinamente integrada à
  IA (`bot_safety.gd`, `bot_steering.gd`) e à câmera.
- **Fase 26** — a auditoria de Google Play desta sessão, verificada 4/4 contra o repositório
  real, com URLs oficiais reconferidas ao vivo.
- Partes do esqueleto de simulação: `MatchDirector`, `TerritoryGrid`, `ArcTracker`, `BotBrain`,
  `Screen`/`ScreenStack` são referenciados e vivos.

## O que fazer com isto

Não apagar código. O material entregue é, em boa parte, **escrito mas não ligado** — religar é
mais barato que reescrever. A ordem sensata é: primeiro a Fase 26.1 (zerar `validate-repo.sh`),
depois fases de religação da simulação (seal, surge, modos, power-ups) e da infraestrutura
(bootstrap, backend, build de release), e só então retomar as fases 27–38.

Nenhuma fase deve ser marcada concluída novamente sem que um teste demonstre a funcionalidade
**alcançável a partir do jogo em execução** — não apenas presente no disco.
