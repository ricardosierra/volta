# Dependências entre fases

> Antes de executar qualquer fase, validar esta tabela. Se uma dependência não estiver
> satisfeita, **parar e reportar** — não improvisar um substituto.

## Grafo

```mermaid
flowchart LR
    P00[00 Discovery] --> P01[01 Repo]
    P01 --> P02[02 Movement]
    P02 --> P03[03 Territory]
    P03 --> P04[04 Combat]
    P04 --> P05[05 Bots]
    P05 --> P06[06 Match Loop]
    P06 --> P07[07 UI/UX]
    P07 --> P08[08 Art]
    P08 --> P09[09 Game Feel]
    P09 --> P10[10 Progression]
    P10 --> P11[11 Cosmetics]
    P06 --> P12[12 Modes]
    P03 --> P13[13 Maps]
    P12 --> P13
    P04 --> P14[14 Power-ups]
    P13 --> P14
    P10 --> P15[15 Backend]
    P15 --> P16[16 Online]
    P16 --> P17[17 Multiplayer]
    P16 --> P18[18 Analytics]
    P14 --> P19[19 Optimization]
    P18 --> P19
    P19 --> P20[20 Accessibility]
    P20 --> P21[21 Android]
    P20 --> P22[22 iOS]
    P21 --> P23[23 Prod Ready]
    P22 --> P23
    P23 --> P24[24 Launch]
    P24 --> P25[25 Post Launch]
```

## Tabela

| Fase | Depende de | O que exige, concretamente |
|---|---|---|
| 01 | 00 | ADRs 0001–0014 aceitos; docs de arquitetura escritos |
| 02 | 01 | Projeto Godot rodando; CI verde; GUT instalado; `ConfigService` carregando `.tres` |
| 03 | 02 | Runner se movendo com posição contínua; tick fixo de 60 Hz funcionando; câmera |
| 04 | 03 | `TerritoryGrid` e `SealSolver` completos e testados; Arc rasterizado 4-conectado |
| 05 | 04 | Break, Backwash, respawn e território liberado na morte funcionando |
| 06 | 05 | Bots jogando partidas completas sem travar; invariantes verdes em 500 partidas |
| 07 | 06 | Ciclo de partida completo com resultado e restart; eventos de score emitidos |
| 08 | 07 | Design system com tokens; todas as telas existindo (mesmo feias) |
| 09 | 08 | Paleta, shaders e assets finais aplicados; zero placeholder de arte |
| 10 | 09 | Save funcionando; eventos de fim de partida com dados completos |
| 11 | 10 | Perfil, inventário e moeda existindo; loja de seleção navegável |
| 12 | 06 | `MatchRulesResource` desacoplado; nenhuma regra de modo hardcoded |
| 13 | 03, 12 | Arena como dado (`ArenaDefinition`), com células bloqueadas suportadas |
| 14 | 04, 13 | `StatBlock` com modificadores empilháveis; spawn de itens no Field |
| 15 | 10 | Contratos de repositório estáveis; formato de save definido |
| 16 | 15 | API no ar com auth, leaderboard, save e config; contratos testados |
| 17 | 16 | Simulação determinística comprovada; API capaz de orquestrar instâncias |
| 18 | 16 | `AnalyticsService` com adapter remoto possível; endpoint de telemetria |
| 19 | 14, 18 | Todas as features de gameplay prontas; métricas reais de dispositivo |
| 20 | 19 | Performance dentro do orçamento; presets de qualidade funcionando |
| 21 | 20 | Build de release limpa, sem debug tools, sem placeholder |
| 22 | 20 | Idem, mais macOS com Xcode disponível |
| 23 | 21, 22 | Ambas as builds validadas em dispositivo real |
| 24 | 23 | Checklist de release fechado; rollback ensaiado |
| 25 | 24 | Jogo publicado e analytics recebendo dados reais |

## Dependências externas (fora do código)

| Item | Necessário em | Dono | Status |
|---|---|---|---|
| Conta Google Play Console (US$ 25) | GSD 21 | humano | ⬜ pendente |
| Conta Apple Developer (US$ 99/ano) | GSD 22 | humano | ⬜ pendente |
| macOS com Xcode 15+ | GSD 22 | humano | ✅ disponível |
| Hospedagem da API (Postgres + Redis) | GSD 15 | humano | ⬜ pendente |
| Domínio + certificado | GSD 15 | humano | ⬜ pendente |
| Busca de anterioridade da marca "VOLTA" | antes da GSD 21 | humano | ⬜ pendente (RISK-012) |
| Aparelho Android intermediário para testes | GSD 02 em diante | humano | ⬜ verificar |
| Fonte licenciada para uso comercial | GSD 08 | humano | ⬜ pendente |

Nenhuma delas bloqueia a GSD 01.

## Regras

1. Fase sem dependência satisfeita **não começa**.
2. Dependência "quase pronta" é dependência não satisfeita.
3. Se uma fase revelar uma dependência não mapeada, esta tabela é atualizada **no mesmo PR**.
4. Fases fora do caminho crítico (13, 17) podem ser adiadas sem bloquear o release — desde que
   registrado em `STATUS.md`.
