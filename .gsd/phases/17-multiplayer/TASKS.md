# GSD 17 — Tarefas

### MPLY-001 — Servidor headless
**Passos:** modo `--headless --server` que instancia a simulação sem apresentação → carregar
modo e arena por parâmetro → laço autoritativo a 60 Hz → encerramento e relatório ao fim.
**Testes:** partida completa só com bots no servidor; resultado idêntico ao do cliente com a
mesma seed (prova de que a simulação é a mesma).
**DoD:** o mesmo código roda nos dois lados, sem `#ifdef` espalhado.

### MPLY-002 — Protocolo
**Arquivos:** `packages/shared/protocol/`.
**Passos:** mensagens binárias compactas: `Input`, `Snapshot`, `SnapshotDelta`, `Event`,
`Join`, `Leave`, `Ping` → versionamento do protocolo → serialização testada nos dois lados.
**Testes:** round-trip de cada mensagem; versão incompatível recusada com mensagem clara.
**DoD:** protocolo documentado em `docs/architecture/networking.md`.

### MPLY-003 — Transporte e sessão
**Passos:** WebSocket (ou ENet, decidido por medição na tarefa) → autenticação com o token da
API → sessão com heartbeat → desconexão detectada rapidamente.
**Testes:** conexão, autenticação, heartbeat, queda de conexão.
**DoD:** decisão de transporte registrada com o número que a motivou.

### MPLY-004 — Predição e reconciliação
**Passos:** cliente prediz só o próprio Runner → guarda inputs não confirmados → ao receber
snapshot, reaplica → erro pequeno corrige suavemente, erro grande faz snap → **território
nunca predito**: a animação de Seal começa otimista e reverte se negada.
**Testes:** com 120 ms de latência, movimento suave; reversão de Seal negado é visualmente
suave e rara; nenhuma divergência de território.
**DoD:** jogável com latência realista.

### MPLY-005 — Interpolação de outros Runners
**Passos:** buffer de ~100 ms → interpolação de posição e direção → extrapolação limitada em
perda de pacote → Arcs dos outros reconstruídos a partir do snapshot.
**Testes:** movimento suave com 5 % de perda; Arc coerente após perda de pacote.
**DoD:** os outros Runners não "teleportam".

### MPLY-006 — Validação de input
**Passos:** taxa máxima de mensagens, timestamps monotônicos, direção normalizada, sequência
coerente → descarte silencioso do inválido, com métrica.
**Testes:** flood, timestamp fora de ordem, direção inválida, sequência repetida.
**DoD:** entrada maliciosa não afeta a partida.

### MPLY-007 — Matchmaking e reconexão
**Passos:** fila por modo e faixa de rank na API → alocação de instância → preenchimento com
bots após espera curta → reconexão em até 30 s, com o Runner em piloto automático defensivo.
**Testes:** fila com 1 jogador (bots preenchem); reconexão restaura estado; timeout vira bot.
**DoD:** ninguém espera mais que o limite configurado.

### MPLY-008 — Teste de latência e carga
**Passos:** simular 60/120/250/400 ms e 0/2/5 % de perda → medir jogabilidade e banda → carga
com N instâncias por vCPU → identificar o gargalo real.
**Testes:** relatório com números; banda < 12 KB/s; ≥ 4 partidas por vCPU.
**DoD:** viabilidade **medida**, não estimada.

### MPLY-009 — Relatório de viabilidade
**Passos:** consolidar o que funciona, o que não funciona, custo de infraestrutura por partida,
riscos e o que falta para produção → recomendação explícita: seguir, adiar ou mudar de abordagem
→ registrar decisão como ADR se mudar algo do ADR-0005.
**Testes:** —
**DoD:** decisão de produto documentada com dados; itens de produção registrados no backlog.
