# Backlog

> Destino de tudo que foi adiado. Uma ideia boa fora do escopo da fase atual **vem para cá**,
> não para o código. Nada some, nada entra de contrabando.

## Como usar

| Campo | Significado |
|---|---|
| ID | `BL-NNN` |
| Tipo | `feature` · `debt` · `bug` · `placeholder` · `mock` · `research` |
| Origem | fase onde apareceu |
| Destino | fase onde deve ser resolvido (obrigatório para `placeholder` e `mock`) |

---

## Placeholders rastreados

| ID | Item | Origem | Destino | Tarefa |
|---|---|---|---|---|
| PLACEHOLDER-ART-001 | Runner: círculo branco | 02 | **08** | ART-002 |
| PLACEHOLDER-ART-002 | Claim: cor chapada | 03 | **08** | ART-003 |
| PLACEHOLDER-ART-003 | Arc: `Line2D` simples | 03 | **08** | ART-004 |
| PLACEHOLDER-ART-004 | Fonte padrão do Godot | 07 | **08** | ART-001 |
| PLACEHOLDER-ART-005 | Ícones de UI: formas básicas | 07 | **08** | ART-007 |
| PLACEHOLDER-ART-006 | Fundo: cor sólida | 02 | **08** | ART-005 |
| PLACEHOLDER-AUDIO-001 | Sem áudio | 06 | **09** | FEEL-006 |

## Mocks rastreados

| ID | Item | Origem | Destino | Tarefa |
|---|---|---|---|---|
| MOCK-001 | `LocalLeaderboardRepository` (só o próprio jogador) | 06 | **16** | ONLN-003 |
| MOCK-002 | `NoopAnalytics` | 06 | **18** | ANLT-002 |
| MOCK-003 | `BakedRemoteConfig` | 01 | **16** | ONLN-006 |
| MOCK-004 | `LocalChallengeRepository` (geração local) | 10 | **16** | ONLN-004 |
| MOCK-005 | Sem verificação de compra | 11 | **25** | POST-005 |

## Itens adiados

| ID | Tipo | Item | Origem | Destino |
|---|---|---|---|---|
| BL-001 | feature | Arenas com paredes móveis (Drift) | 00 | pós-launch |
| BL-002 | feature | Arena com portais (Gate) | 00 | pós-launch |
| BL-003 | feature | Arena labirinto (Lattice) | 00 | pós-launch |
| BL-004 | feature | Season pass cosmético | 00 | 25 |
| BL-005 | feature | Eventos de fim de semana e sazonais | 00 | 25 |
| BL-006 | feature | Clãs / times | 00 | não planejado |
| BL-007 | feature | Retomar partida em andamento | 00 | não planejado |
| BL-008 | feature | Replay de partida (a serialização já suporta) | 00 | pós-launch |
| BL-009 | feature | Leaderboard por país e por amigos | 00 | 16 |
| BL-010 | feature | Vincular conta a Google Play Games / Game Center | 00 | 16 |
| BL-011 | research | Avaliar upgrade da engine | 00 | 20 |
| BL-012 | research | `SealSolver` em GDExtension, se necessário | 00 | 19 |
| BL-013 | research | Chunks no grid para arenas > 512² | 00 | condicional |
| BL-014 | feature | Idiomas além de en e pt-BR | 00 | pós-launch |
| BL-015 | feature | Anúncios rewarded | 00 | 25 |
| BL-016 | feature | Modo espectador / compartilhar recorde em vídeo | 00 | pós-launch |
| BL-017 | debt | Decidir Final Push em Domination | 00 | Alpha |
| BL-018 | debt | Decidir se roubo dá Surge extra | 00 | Alpha |

## Bugs conhecidos

| ID | Severidade | Descrição | Encontrado em | Status |
|---|---|---|---|---|
| — | — | *(nenhum: implementação não iniciada)* | — | — |

Severidade: `blocker` (impede release) · `critical` (quebra gameplay) · `major` · `minor` · `trivial`.

## Regras

1. Placeholder e mock **precisam** de fase de destino. Sem destino, não entra no código.
2. O CI reprova placeholder que sobreviveu à fase declarada.
3. Ideia nova durante uma fase → aqui, com uma linha. Nunca no meio do trabalho em curso.
4. Bug encontrado fora do escopo da fase → aqui, com severidade. `blocker` e `critical`
   interrompem a fase atual.
