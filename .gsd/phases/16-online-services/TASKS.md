# GSD 16 — Tarefas

### ONLN-001 — `ApiClient`
**Passos:** requisição tipada com timeout de 8 s → 2 retries com backoff e jitter →
`Idempotency-Key` automático em escrita → mapeamento de erro por código estável →
nenhuma chamada em `_process` ou `_physics_process`.
**Testes:** timeout, retry, erro 4xx sem retry, 5xx com retry, cancelamento.
**DoD:** nenhuma chamada de rede no caminho de simulação.

### ONLN-002 — Fila offline e `RemoteProfileRepository`
**Passos:** fila persistida no `user://` com deduplicação por chave → drenagem oportunista →
`RemoteProfileRepository` com cache local como fonte de leitura imediata.
**Testes:** app morto no meio da fila; item nunca duplica; ordem preservada; fila limitada.
**DoD:** offline e online usam o mesmo caminho de código do jogo.

### ONLN-003 — `RemoteLeaderboardRepository` (fecha MOCK-001)
**Passos:** submissão pela fila → leitura com cache e TTL → as 6 abas → posição própria fixada
no rodapé → estado de "sem conexão" informativo, não alarmante.
**Testes:** submissão offline chega depois; cache expira; abas corretas.
**DoD:** MOCK-001 fechado no `BACKLOG.md`.

### ONLN-004 — `RemoteChallengeRepository` (fecha MOCK-004)
**Passos:** desafios do servidor, iguais para todos → progresso local validado no resgate →
fallback para geração local se a API não responder no primeiro acesso do dia.
**Testes:** fallback funciona; resgate único; progresso local e remoto reconciliados.
**DoD:** MOCK-004 fechado.

### ONLN-005 — Cloud save
**Passos:** exportar/importar blob → sincronização em pontos seguros (boot, fim de partida,
background) → resolução de conflito conforme a API → aviso claro quando o servidor tem progresso
maior (com escolha do jogador em caso ambíguo).
**Testes:** conflito nos dois sentidos; app em dois "aparelhos" simulados; nunca perde XP.
**DoD:** trocar de aparelho preserva progresso.

### ONLN-006 — `HttpRemoteConfig` (fecha MOCK-003)
**Passos:** busca com ETag no boot → validação de faixa **no cliente também** → aplicação só
fora de partida → fallback embutido em qualquer falha.
**Testes:** config inválida ignorada com log; falha de rede usa embutido; nunca aplica durante
`Playing`.
**DoD:** MOCK-003 fechado.

### ONLN-007 — Tela de Leaderboard
**Passos:** 6 abas (Diário, Semanal, Mensal, Geral, Amigos, País) → sua posição fixada no rodapé
→ estados de carregando, vazio e offline → paginação com scroll infinito.
**Testes:** layout na matriz; estados; paginação.
**DoD:** carrega em < 500 ms com cache.

### ONLN-008 — Vinculação de conta
**Passos:** opcional, em `Settings > Conta` → Google Play Games / Game Center → recuperação em
aparelho novo → possibilidade de desvincular.
**Testes:** vincular, desvincular, recuperar em dispositivo limpo.
**DoD:** jogar nunca exige login.

### ONLN-009 — Validação offline-first
**Passos:** bateria de testes em modo avião: partida completa, progressão, desafios, cosméticos,
recordes locais → religar a rede e verificar sincronização → simular servidor fora do ar (500) e
lento (5 s) → medir impacto no boot.
**Testes:** nenhuma diferença perceptível offline; sincronização correta ao voltar; boot nunca
espera rede.
**DoD:** relatório com os 3 cenários (offline, servidor lento, servidor fora).
