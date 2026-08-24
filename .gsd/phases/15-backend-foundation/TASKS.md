# GSD 15 — Tarefas

### API-001 — Projeto Laravel e ambiente
**Arquivos:** `services/api/`, `docker-compose.yml`, `services/api/README.md`.
**Passos:** Laravel 11 em `services/api` → Docker com Postgres 16 e Redis 7 → `.env.example` →
Pint, PHPStan nível 6, Pest → script `tools/dev/api_up.sh`.
**Testes:** `php artisan test` verde; `docker compose up` sobe tudo.
**DoD:** qualquer pessoa sobe o ambiente com um comando.

### API-002 — Migrações e modelos
**Passos:** tabelas de `docs/backend/api-design.md` §Modelo → índices (leaderboard, matches por
jogador e data) → todas as migrações reversíveis → factories e seeders.
**Testes:** migrate/rollback limpo; índices presentes; factories geram dado válido.
**DoD:** schema coerente com o documento.

### API-003 — Autenticação por dispositivo
**Passos:** `POST /auth/device` cria ou recupera conta a partir de `device_id` (armazenado como
**hash**) → Sanctum com escopo → refresh com invalidação → rate limit por IP.
**Testes:** criação, recuperação, token inválido, refresh, rate limit.
**DoD:** jogar não exige cadastro.

### API-004 — Perfil e estatísticas
**Passos:** `GET/PATCH /profile` → sanitização de apelido (lista de bloqueio + normalização
Unicode contra homóglifos) → estatísticas agregadas atualizadas por job.
**Testes:** edição válida e inválida; apelido ofensivo e com homóglifo rejeitados.
**DoD:** perfil é fonte de verdade do servidor.

### API-005 — Submissão e validação de partida
**Objetivo:** o núcleo do anti-cheat. **Contexto:** `docs/backend/anti-cheat.md`.
**Passos:** `POST /matches` com `Idempotency-Key` → recálculo do score a partir dos agregados →
validação de plausibilidade (duração, taxa de captura, Seals por segundo, Breaks possíveis,
teto de Surge, `largest_seal <= claim_pct`) → assinatura HMAC verificada → `flags` em vez de
banimento automático → processamento na fila.
**Testes:** 8 casos de limite; partida válida aceita; duplicada ignorada; score forjado rejeitado.
**DoD:** nenhum score entra no leaderboard sem passar por aqui.

### API-006 — Leaderboards
**Passos:** Redis ZSET por board e período; Postgres como verdade durável → `GET /leaderboards/{board}`
com paginação e `me` com vizinhança → job de reconciliação → rotação de período com chave de data.
**Testes:** ordenação, empate, paginação, posição própria, virada de período, reconstrução a
partir do Postgres.
**DoD:** leitura < 50 ms; recorde só entra depois da fila.

### API-007 — Cloud save
**Passos:** `GET/PUT /save` com validação de schema e tamanho → `updated_at` do **servidor** →
reconciliação monotônica de XP, conquistas e inventário → últimas 3 versões guardadas.
**Testes:** conflito resolvido sem perda; blob inválido rejeitado; downgrade de schema tratado;
restauração de versão anterior.
**DoD:** impossível perder progresso por sincronização.

### API-008 — Desafios diários
**Passos:** definição em tabela → job de rotação diária (mesmos desafios para todos) →
`GET /challenges/daily`, `POST /challenges/{id}/claim` com idempotência → validação de progresso
contra as partidas submetidas.
**Testes:** rotação, resgate único, fuso, progresso inconsistente rejeitado.
**DoD:** desafio online é confiável.

### API-009 — Remote config
**Passos:** `GET /config` com ETag e cache → só sobrescreve chaves existentes, respeitando as
faixas declaradas → versionamento de config → rota administrativa protegida.
**Testes:** chave nova rejeitada; valor fora de faixa rejeitado; ETag 304.
**DoD:** impossível quebrar o jogo por config remota.

### API-010 — Segurança e rate limiting
**Contexto:** `docs/backend/security.md`.
**Passos:** limites de `api-design.md` §Rate limits → HTTPS/HSTS → cabeçalhos de segurança →
`composer audit` no CI → logs sem PII → usuário de banco sem privilégio excessivo.
**Testes:** limites por rota; requisição sem token; token expirado; auditoria de dependências.
**DoD:** checklist de `security.md` cumprida.

### API-011 — CI da API
**Arquivos:** `.github/workflows/api-ci.yml`.
**Passos:** Pint, PHPStan, Pest com Postgres e Redis como serviços → cobertura → cache de
Composer → gate de merge.
**Testes:** workflow verde; PR com erro proposital reprovado.
**DoD:** CI da API obrigatório no merge.

### API-012 — Deploy e operação
**Arquivos:** `docs/deployment/api-deploy.md`, `services/api/README.md`.
**Passos:** documentar deploy (migrações, filas, supervisor, health check) → backup diário do
Postgres com **restauração testada** → monitoramento básico e alertas → runbook de incidente.
**Testes:** restauração de backup executada de verdade em ambiente limpo.
**DoD:** operação documentada a ponto de outra pessoa executar.
