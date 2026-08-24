# Rede e serviços

> Princípio: **nada online antes da hora**. Até GSD 15 tudo é local — mas atrás de interfaces
> que já têm o formato certo, para que trocar `Local*` por `Remote*` seja um registro no
> bootstrap, não uma refatoração.

## 1. Padrão de repositório

```text
LeaderboardRepository        (interface)
├── LocalLeaderboardRepository     GSD 06 — arquivo local, recordes do próprio jogador
└── RemoteLeaderboardRepository    GSD 16 — API, cache com TTL, fila offline

ProfileRepository
├── LocalProfileRepository         GSD 10
└── RemoteProfileRepository        GSD 16

ChallengeRepository
├── LocalChallengeRepository       GSD 10 — geração local com seed diária
└── RemoteChallengeRepository      GSD 16 — desafios servidos, iguais para todos

RemoteConfigService
├── BakedRemoteConfig              GSD 01 — lê os .tres embutidos
└── HttpRemoteConfig               GSD 16 — busca, valida, cacheia, faz fallback no embutido

AnalyticsService
├── NoopAnalytics                  GSD 06
├── LocalFileAnalytics             GSD 18 — debug
└── RemoteAnalytics                GSD 18
```

Regra: **toda** implementação remota tem fallback local e nunca bloqueia o gameplay.
Sem rede, o jogo é 100 % jogável. Isso não é um modo degradado — é o comportamento padrão.

## 2. Camada HTTP (GSD 15/16)

```gdscript
class_name ApiClient
func request(method: String, path: String, body: Dictionary, opts: RequestOptions) -> ApiResponse
```

- Timeout curto (padrão 8 s), 2 retries com backoff exponencial e jitter.
- Toda escrita é **idempotente** por `Idempotency-Key`.
- Fila offline persistente para escritas (submissão de score, progresso): grava, tenta depois,
  nunca perde e nunca duplica.
- Erros nunca aparecem como popup no meio da partida. No máximo um ícone discreto de
  "sincronizando" no menu.
- Nenhum segredo real embutido no cliente. Ver `backend/security.md`.

## 3. Multiplayer (GSD 17)

**Decisão:** servidor autoritativo rodando o **mesmo código de simulação** do cliente, em
Godot headless. Registrada em [`ADR-0005`](../decisions/ADR-0005-networking.md).

Motivo central: a simulação de território **precisa** ser idêntica nos dois lados. Reimplementar
o `SealSolver` em outra linguagem no servidor seria garantir divergência — e divergência de
território é o pior bug possível neste jogo.

```text
Cliente                                  Servidor (Godot headless)
  input (dir desejada) ──── 20 Hz ───────►  aplica no tick autoritativo
  predição local do próprio Runner          simula 60 Hz, autoridade total
  interpolação dos outros (100 ms buffer)   snapshot delta ──── 15 Hz ───► clientes
  reconciliação ao receber snapshot         valida plausibilidade do input
```

| Assunto | Abordagem |
|---|---|
| **Movimento** | predição no cliente + reconciliação; erro pequeno é corrigido suavemente, erro grande faz snap |
| **Território** | **nunca** predito. O Seal só acontece quando o servidor confirma. A animação local começa otimista e é revertida se negada (raro). |
| **Latência** | alvo ≤ 120 ms RTT; acima de 250 ms o jogador é avisado |
| **Anti-cheat** | servidor é a única fonte de verdade; input impossível é descartado; ver `backend/anti-cheat.md` |
| **Reconexão** | 30 s de janela; o Runner fica em piloto automático defensivo (não some do mapa) |
| **Matchmaking** | fila por modo + faixa de rank, com preenchimento por bots após espera curta |
| **Escala** | uma instância headless por partida, orquestrada pela API; partidas de 6–8 Runners |

**Explicitamente proibido:** sincronizar `Node`s do Godot pela rede e torcer para a física
concordar. Sincronizamos **estado de simulação**, que é determinístico por construção (R8.5).

## 4. Ordem de implementação

| Fase | Entrega |
|---|---|
| GSD 06 | interfaces + implementações locais |
| GSD 15 | API Laravel: auth, perfil, leaderboard, cloud save, remote config |
| GSD 16 | trocar `Local*` por `Remote*` no bootstrap; fila offline; desafios online |
| GSD 17 | protótipo de servidor autoritativo, protocolo, reconciliação, teste de latência |
| pós-launch | multiplayer em produção (só depois do core estar sólido) |
