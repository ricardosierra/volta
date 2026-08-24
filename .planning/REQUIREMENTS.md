# Requirements — v0.1.0

Requisitos derivados de `docs/` e de `.gsd/phases/*/REQUIREMENTS.md`. IDs usados no ROADMAP.

## Fundação (FND)

- [x] FND-01 — Projeto Godot 4.3 abre, roda em mobile e tem versão pinada
- [x] FND-02 — Configuração orientada a dados (`.tres`) com validação de faixa
- [x] FND-03 — Save versionado com escrita atômica, backup e migrações
- [x] FND-04 — Logging estruturado por categoria e nível
- [ ] FND-05 — CI com lint, validação de convenções e testes headless
- [ ] FND-06 — Verificadores de convenção que falham de verdade (8 regras)

## Movimento e controle (MOV)

- [ ] MOV-01 — Simulação 60 Hz fixa com interpolação visual
- [ ] MOV-02 — Movimento em ângulo livre com taxa máxima de giro
- [ ] MOV-03 — Três esquemas de controle (swipe, joystick, relativo)
- [ ] MOV-04 — Buffer de input: nenhum toque descartado
- [ ] MOV-05 — Latência toque → direção < 50 ms
- [ ] MOV-06 — Câmera com follow, lookahead e zoom dinâmico
- [ ] MOV-07 — FSM do jogo e FSM do Runner com transições declaradas

## Território (TER)

- [ ] TER-01 — Grid denso com consultas O(1) e contagem incremental
- [ ] TER-02 — Arc rasterizado com conectividade de 4 vizinhos garantida
- [ ] TER-03 — Seal por flood fill do exterior, custo proporcional à região
- [ ] TER-04 — Roubo de território, Claim desconectado, buraco e borda tratados
- [ ] TER-05 — Overload do Arc com aviso e decaimento
- [ ] TER-06 — Render por textura com `dirty_rect`, 1 draw call
- [ ] TER-07 — Serialização do grid e invariantes verificadas por tick

## Combate (CMB)

- [ ] CMB-01 — Break ao cortar Arc inimigo; território liberado ao neutro
- [ ] CMB-02 — Backwash em auto-colisão e barreira, mantendo vulnerabilidade
- [ ] CMB-03 — Squeeze, morte mútua e ordem determinística de tick
- [ ] CMB-04 — Respawn em local válido com invulnerabilidade
- [ ] CMB-05 — Lista de causas de morte fechada e aviso periférico de ameaça

## Adversários (BOT)

- [ ] BOT-01 — IA por utilidade com perfis em `.tres`
- [ ] BOT-02 — 7 arquétipos distinguíveis, 4 no MVP
- [ ] BOT-03 — Dificuldade por comportamento, nunca por velocidade
- [ ] BOT-04 — Segurança: anti-travamento, anti-suicídio, anti-estagnação
- [ ] BOT-05 — Orçamento de CPU respeitado com escalonamento de decisões

## Partida (MTC)

- [ ] MTC-01 — Countdown, fim de partida e ranking com desempate
- [ ] MTC-02 — Score conforme fórmula documentada, com tetos
- [ ] MTC-03 — Surge e os 9 bônus nomeados
- [ ] MTC-04 — Resultado com PLAY AGAIN em um toque (< 0,8 s)
- [ ] MTC-05 — 5 modos de jogo sobre a mesma simulação
- [ ] MTC-06 — 5 arenas que mudam a estratégia
- [ ] MTC-07 — 6 power-ups com contra-jogo, sem vantagem vendável

## Interface e apresentação (UIX)

- [ ] UIX-01 — Design system em tokens, 12 componentes, showcase
- [ ] UIX-02 — Todas as telas, navegação e settings funcionais
- [ ] UIX-03 — Responsivo de 16:9 a 20:9 + tablet, safe area, escala de UI
- [ ] UIX-04 — i18n (en + pt-BR) desde o primeiro texto
- [ ] UIX-05 — Onboarding dentro da partida, 6 passos
- [ ] UIX-06 — HUD com no máximo 5 elementos permanentes

## Arte, feel e áudio (ART)

- [ ] ART-01 — Direção de arte aplicada; zero placeholder
- [ ] ART-02 — 8 temas com contraste e separação de matiz verificados
- [ ] ART-03 — Identificação por cor + forma + padrão
- [ ] ART-04 — Contrato dos 7 canais cumprido em toda ação principal
- [ ] ART-05 — Áudio adaptativo por camadas + SFX com variações
- [ ] ART-06 — Háptico contextual com Off/Light/Full

## Progressão e cosméticos (PRG)

- [ ] PRG-01 — Perfil, XP, ranks e estatísticas persistidos
- [ ] PRG-02 — Conquistas e desafios diários/semanais
- [ ] PRG-03 — Carteira com tetos e histórico
- [ ] PRG-04 — Catálogo cosmético como dado, sem impacto de gameplay

## Serviços (SRV)

- [ ] SRV-01 — API Laravel com auth por dispositivo e rate limiting
- [ ] SRV-02 — Score recalculado no servidor com validação de plausibilidade
- [ ] SRV-03 — Leaderboards, cloud save, desafios e remote config
- [ ] SRV-04 — Cliente offline-first: sem rede, nada muda
- [ ] SRV-05 — Analytics e crash reporting sem PII, com opt-out real
- [ ] SRV-06 — Arquitetura de multiplayer autoritativo provada em protótipo

## Qualidade e release (QLT)

- [ ] QLT-01 — Orçamento de performance respeitado nos 3 tiers
- [ ] QLT-02 — Acessibilidade visual, motora, auditiva e cognitiva
- [ ] QLT-03 — Matriz de dispositivos validada
- [ ] QLT-04 — Build Android e iOS assinadas, sem debug, dentro do tamanho
- [ ] QLT-05 — Migração de save testada e rollback ensaiado
- [ ] QLT-06 — Lançamento com rollout gradual e monitoramento
