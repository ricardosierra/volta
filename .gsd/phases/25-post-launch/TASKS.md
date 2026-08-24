# GSD 25 — Tarefas (ciclo contínuo)

### POST-001 — Balanceamento por dados
**Passos:** analisar distribuição de território final, vitórias por arquétipo, mortes por causa,
frequência de Backwash, uso de power-ups e duração por modo → ajustar `.tres` → validar por
simulação → publicar via remote config quando possível, evitando build nova → registrar no
histórico de `balance.md`.
**DoD:** todo ajuste com antes/depois medido, nunca com "parece melhor".

### POST-002 — Correções e melhorias
**Passos:** triagem de crash e feedback → corrigir por severidade → hotfix `patch` para crítico,
minor para melhorias → responder avaliações.
**DoD:** crash-free ≥ 99,5 % mantido.

### POST-003 — Monetização
**Passos:** rewarded ads nos dois pontos definidos (resultado e desafios), com limites diários →
IAP de Prisms e remove ads, com validação de recibo no servidor → preços por região (H-05) →
métricas éticas monitoradas.
**Testes:** compra, restauração, reembolso revoga item, recibo duplicado rejeitado.
**DoD:** nenhum ponto de fricção artificial criado.

### POST-004 — Temporadas e eventos
**Passos:** arquitetura de temporada (período, trilha cosmética, desafios próprios) → eventos de
fim de semana e sazonais → arenas e regras especiais por tempo limitado → tudo configurável por
servidor, sem build nova.
**DoD:** temporada pode começar e terminar sem publicar versão.

### POST-005 — Season pass cosmético
**Passos:** trilha gratuita com cosméticos reais + trilha paga com mais itens → progresso por
XP de temporada → nada que afete o jogo → itens permanentes, mesmo após a temporada.
**DoD:** revisão contra a política de monetização, item a item.

### POST-006 — Conteúdo novo
**Passos:** arenas do backlog (`Lattice`, `Drift`, `Gate`) → modos novos, se os dados pedirem →
cosméticos → cada adição passa pelos mesmos gates de qualidade e stress test.
**DoD:** conteúdo novo não degrada performance nem estabilidade.

### POST-007 — Operação e suporte
**Passos:** canal de suporte com prazo de resposta → monitoramento e alertas → post-mortem de
incidente em `docs/backend/incidents/` → revisão trimestral de dependências e de segurança →
revisão do roadmap com dados.
**DoD:** operação previsível, sem heroísmo.
