# MASTER PLAN — VOLTA

> **Status do plano: READY.** Nenhuma decisão arquitetural fundamental permanece em aberto.
> Todas as 26 fases podem ser executadas em sequência sem reinterpretar o projeto.

| | |
|---|---|
| Projeto | **VOLTA** — arcade mobile de conquista territorial |
| Engine | Godot 4.3 stable, GDScript tipado |
| Plataformas | Android (primária), iOS |
| Backend | Laravel 11 + PostgreSQL + Redis (a partir de GSD 15) |
| Fases | 26 (GSD 00 → GSD 25) |
| Marcos | MVP (fim da 06) · Alpha (fim da 14) · Beta (fim da 20) · Release v0.1.0 (fim da 24) |
| Fase atual | **GSD 01 — Repository Foundation** |
| Implementação | **NOT STARTED** |

---

## 1. Como este plano funciona

Cada fase é uma pasta em `phases/` com sete documentos. Cada tarefa tem ID, objetivo, contexto,
dependências, arquivos afetados, passos de implementação, testes e *Definition of Done*.

Um agente executa uma fase com:

```text
Execute GSD 01
```

E encerra com um `HANDOFF.md`, um quality gate fechado e o `STATUS.md` atualizado.
Protocolo completo em [`COMMANDS.md`](COMMANDS.md).

---

## 2. As 26 fases

| # | Fase | Objetivo em uma frase | Tarefas | Marco |
|---|---|---|---|---|
| **00** | Discovery & Product Definition | Definir visão, pilares, regras, stack e arquitetura | 8 | ✅ concluída |
| **01** | Repository Foundation | Monorepo, projeto Godot, CI, lint, testes, base mobile | 12 | |
| **02** | Core Movement | Arena, Runner, input, movimento, câmera, FSM do jogo | 10 | |
| **03** | **Territory Engine** | Grid, Arc, flood fill, Seal, render incremental | 14 | ⚠️ crítica |
| **04** | Combat & Elimination | Colisão com Arc, Break, morte, respawn, Backwash | 9 | |
| **05** | Bot AI | Bots por utilidade, arquétipos, dificuldade, stress test | 11 | |
| **06** | Complete Match Loop | Countdown, score, fim, resultado, restart | 10 | 🏁 **MVP** |
| **07** | UI/UX Foundation | Design system, telas, HUD, navegação, settings, i18n | 12 | |
| **08** | Art Direction | Paletas, shaders, território, Arc, fundo, zero placeholder | 11 | |
| **09** | Game Feel & Polish | VFX, câmera, háptico, SFX, música adaptativa, transições | 10 | |
| **10** | Progression | Perfil, XP, ranks, estatísticas, conquistas, desafios | 10 | |
| **11** | Cosmetics | Skins, temas, Arcs, efeitos de Seal, desbloqueio, seleção | 8 | |
| **12** | Additional Game Modes | Time Attack, Survival, Domination, Endless | 9 | |
| **13** | Maps & Arena Variations | Archipelago, Rift, Crossroads, Halo | 8 | |
| **14** | Power-ups | Os 6 power-ups, `StatBlock`, balanceamento | 8 | 🏁 **Alpha** |
| **15** | Backend Foundation | Laravel: auth, perfil, leaderboard, cloud save, config | 12 | |
| **16** | Online Services | Trocar repositórios locais por remotos, fila offline | 9 | |
| **17** | Multiplayer Architecture | Servidor autoritativo headless: protótipo e protocolo | 9 | |
| **18** | Analytics & Telemetry | Eventos, crash reporting, métricas de performance | 8 | |
| **19** | Optimization | Profiling completo, orçamentos, pooling, memória | 9 | |
| **20** | Accessibility & Devices | Safe area, tablets, low-end, 120 Hz, acessibilidade | 9 | 🏁 **Beta** |
| **21** | Android Release | Build, assinatura, AAB, ícones, permissões, loja | 9 | |
| **22** | iOS Release | Xcode, assinatura, entitlements, TestFlight, loja | 8 | |
| **23** | Production Readiness | QA, regressão, crash, migração de save, validação | 8 | |
| **24** | Launch | Versionamento, changelog, release, rollout, rollback | 7 | 🏁 **v0.1.0** |
| **25** | Post Launch | Balanceamento por dados, temporadas, conteúdo, live ops | 7 | |

---

## 3. Caminho crítico

```text
01 → 02 → 03 → 04 → 05 → 06   (MVP: um jogo completo, feio)
                     ↓
        07 → 08 → 09          (parece produto)
                     ↓
     10 → 11 → 12 → 13 → 14   (Alpha: conteúdo e progressão)
                     ↓
        15 → 16 → 18 → 19 → 20 (Beta: serviços, dados, qualidade)
              ↓
             17               (multiplayer: arquitetura, fora do caminho crítico do release)
                     ↓
        21 → 22 → 23 → 24     (Release)
                     ↓
             25               (Live ops)
```

**GSD 03 é o gargalo técnico do projeto.** Se ela for mal feita, todas as fases seguintes
pagam a conta. É a única fase com orçamento de tempo deliberadamente folgado e com benchmark
obrigatório desde a primeira linha.

---

## 4. Princípios de execução

1. **Uma fase por vez.** Nada de implementar a 08 durante a 03 porque "já estava ali".
2. **Nada de mock eterno.** Todo mock nasce com `Replacement Phase` e `Replacement Task`.
3. **Nada de placeholder órfão.** Todo `PLACEHOLDER-ART-XXX` tem fase de substituição.
4. **Nada de TODO anônimo.** `TODO(GSD-XX/TASK-YYY):` ou o CI reprova.
5. **Teste junto, não depois.** Tarefa sem teste não fecha.
6. **Performance é requisito**, não polimento: orçamento validado a cada fase que toca o
   caminho quente.
7. **Documento desatualizado bloqueia o gate.** Documentação é entrega, não favor.
8. **Autonomia técnica.** Duas soluções aceitáveis? Escolher a melhor, registrar, seguir.
   Interromper humano só para: produto, custo, credencial, jurídico, publicação e decisões
   irreversíveis relevantes.
9. **Auditoria contínua.** Ao fim de cada fase, procurar regressão, duplicação, código morto,
   inconsistência arquitetural e doc desatualizado. Corrigir o que é da fase; registrar o resto.
10. **Funcionar não basta.** Toda feature com representação visual responde por alinhamento,
    espaçamento, animação, feedback, contraste, legibilidade, consistência e responsividade.

---

## 5. Definition of Done (vale para toda tarefa)

```text
1. o código existe
2. o código funciona
3. o código foi testado
4. edge cases foram considerados
5. a documentação foi atualizada
6. não deixou TODO crítico nem sem referência de tarefa
7. não introduziu regressão
8. respeita a arquitetura (camadas, tipagem, sem arquivo-depósito)
9. funciona no contexto real do jogo, num dispositivo real quando aplicável
```

---

## 6. Marcos e critérios

| Marco | Fecha em | Critério resumido |
|---|---|---|
| **MVP** | GSD 06 | Jogo completo do início ao fim, 60 FPS no Mid, zero bug crítico |
| **Alpha** | GSD 14 | Parece produto: arte, feel, progressão, 5 modos, 5 arenas, zero placeholder |
| **Beta** | GSD 20 | Backend, analytics, acessibilidade, matriz de dispositivos, crash-free ≥ 99 % |
| **Release v0.1.0** | GSD 24 | Checklist de release inteiro fechado |

Detalhes em [`../docs/product/roadmap.md`](../docs/product/roadmap.md).

---

## 7. Onde encontrar as respostas

| Pergunta | Documento |
|---|---|
| Por que essa decisão? | `docs/decisions/ADR-*` |
| Qual é a regra? | `docs/gameplay/rules.md` |
| Qual é o número? | `docs/design/balance.md` |
| Como o território funciona? | `docs/architecture/territory-system.md` |
| Qual é o orçamento? | `docs/performance/performance-budget.md` |
| O que falta fazer? | `.gsd/STATUS.md` e `.gsd/BACKLOG.md` |
| O que pode dar errado? | `.gsd/RISKS.md` |
| Quando uma fase acaba? | `.gsd/QUALITY_GATES.md` |
