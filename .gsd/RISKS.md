# Riscos

Escala: probabilidade e impacto de 1 (baixo) a 5 (alto). **Score = P × I.**
Score ≥ 12 exige mitigação ativa **agora**, não "quando aparecer".

| # | Risco | P | I | Score | Fase | Mitigação | Dono |
|---|---|---|---|---|---|---|---|
| **RISK-001** | O `SealSolver` fica lento ou incorreto e contamina o projeto inteiro | 3 | 5 | **15** | 03 | Benchmarks B01–B15 desde a primeira linha; solver puro e testável; 30 casos de mesa; estratégias de otimização já mapeadas | técnico |
| **RISK-002** | O Arc rasterizado vaza pela diagonal e o Seal captura o mapa | 3 | 5 | **15** | 03 | Traçado supercover + teste de propriedade com trajetos aleatórios; invariante de 4-conectividade verificada em todo tick do stress test | técnico |
| **RISK-003** | Bots parecem burros e a experiência offline desaba | 3 | 5 | **15** | 05 | IA por utilidade com overlay de intenção; distribuição de vitórias medida em 500 partidas; legibilidade testada em playtest | técnico |
| **RISK-004** | 60 FPS não se sustentam no aparelho Mid | 3 | 4 | **12** | 19 | Orçamento por subsistema desde a GSD 02; medição em dispositivo real a cada fase; presets de qualidade | técnico |
| **RISK-005** | O jogo funciona mas não é divertido | 2 | 5 | 10 | 06 | MVP jogável cedo; playtest com pessoas de fora no gate da Alpha; métrica-norte de partidas por sessão | produto |
| **RISK-006** | Escopo cresce e o release nunca chega | 4 | 3 | **12** | todas | Fases fechadas; ideia nova vai para o `BACKLOG.md`, não para a fase atual; marcos com critério objetivo | processo |
| **RISK-007** | Backwash vira estratégia degenerada (raspar o próprio Arc de propósito) | 2 | 3 | 6 | 05/19 | Frequência medida no stress test; penalidade ajustável por dado antes de mudar regra | design |
| **RISK-008** | Snowball de Surge torna partidas decididas cedo | 2 | 3 | 6 | 06 | Teto de nível, decaimento, e bots `Baron`/`Nemesis` que caçam o líder; medido em 500 partidas | design |
| **RISK-009** | Save corrompido causa perda de progresso e avaliações 1 estrela | 2 | 5 | 10 | 01/10 | Escrita atômica, backup, migrações com fixture, nunca apagar arquivo suspeito | técnico |
| **RISK-010** | Loja rejeita a build (privacidade, conteúdo, metadados) | 2 | 4 | 8 | 21/22 | Checklist de release; Data Safety e Privacy Label preenchidos com a coleta real; nenhuma tela de debug na build | processo |
| **RISK-011** | Backend indisponível degrada o jogo | 2 | 3 | 6 | 16 | Offline-first por construção: todo remoto tem fallback local e nada bloqueia gameplay | técnico |
| **RISK-012** | Conflito de marca no nome "VOLTA" | 3 | 4 | **12** | antes da 21 | Busca de anterioridade antes da GSD 21; nome isolado em tokens/strings para renomear barato; `com.ricardosierra.volta` trocável até lá | **humano** |
| **RISK-013** | Godot 4.3 impõe limitação inesperada em mobile | 2 | 4 | 8 | 02/20 | Validação em dispositivo real desde a GSD 02; upgrade avaliado na GSD 20 com custo medido |técnico |
| **RISK-014** | Determinismo quebra e o servidor autoritativo fica inviável | 2 | 4 | 8 | 03/17 | Tick fixo, ordem estável, invariante de determinismo no stress test (mesma seed → mesmo resultado) | técnico |
| **RISK-015** | Analytics coleta demais e vira problema de privacidade | 2 | 4 | 8 | 18 | Interface própria com um único ponto de saída; zero PII; opt-out real; revisão do plano antes de implementar | processo |
| **RISK-016** | Trabalho de arte não fecha e o jogo parece protótipo | 2 | 4 | 8 | 08 | Arte vetorial/procedural (barata de produzir); placeholders rastreados que reprovam o gate da Alpha | produto |
| **RISK-017** | Multiplayer é iniciado cedo demais e trava o release | 2 | 5 | 10 | 17 | GSD 17 entrega arquitetura + protótipo, explicitamente **não** um recurso lançável; fora do caminho crítico |processo |
| **RISK-018** | Testes headless não representam o jogo real e dão falsa segurança | 2 | 3 | 6 | 05 | Toda fase também exige verificação em dispositivo; invariantes cobrem estado, não só "não crashou" | processo |
| **RISK-019** | Dependência externa (conta de loja, hospedagem) atrasa o release | 3 | 3 | 9 | 15/21/22 | Mapeadas em `DEPENDENCIES.md` com dono humano e prazo antecipado | **humano** |
| **RISK-020** | Perda de contexto entre sessões degrada a execução | 3 | 3 | 9 | todas | `STATUS.md` sempre atualizado; `HANDOFF.md` por fase; tarefas autocontidas com arquivos e passos | processo |

## Riscos com score ≥ 12 — ação imediata

| Risco | Ação já embutida no plano |
|---|---|
| RISK-001 | GSD 03 tem 14 tarefas, benchmark obrigatório e prazo folgado de propósito |
| RISK-002 | `TERR-003` entrega a rasterização com teste de propriedade **antes** do solver |
| RISK-003 | GSD 05 inclui overlay de intenção e critérios objetivos de legibilidade |
| RISK-004 | Toda fase que toca o caminho quente valida orçamento antes de fechar |
| RISK-006 | `BACKLOG.md` existe desde o dia 1 e é o destino de toda ideia fora de escopo |
| RISK-012 | Registrado como decisão humana com prazo (H-01) e citado em `docs/product/vision.md` |

## Revisão

Riscos são revisados no fim de cada fase, no `HANDOFF.md`. Risco novo entra aqui com P, I,
mitigação e dono — nunca só como observação em prosa.
