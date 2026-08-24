# ADR-0003 — Save, versionamento e migração

## Context

Perder progresso é a forma mais rápida de perder um jogador. Precisamos persistir settings,
perfil, progressão, inventário, conquistas, desafios e recordes; sobreviver a queda de energia
e a app morto pelo sistema; permitir evolução do schema por anos; e mais tarde sincronizar com
a nuvem sem reescrever tudo.

## Decision

**JSON legível** em `user://save/`, com escrita **atômica** (tmp → fsync → backup → rename),
arquivo de backup `.bak`, e `meta.schema_version` inteiro com **migrações encadeadas**
(1→2→3, nunca pulando). `settings.json` é separado de `profile.json`, para que corrupção de
perfil não leve as preferências junto.

Corrupção nunca apaga nada: tenta o backup; se também falhar, cria perfil novo e **renomeia**
os arquivos suspeitos para `.corrupt-<timestamp>`.

Save de versão **futura** (downgrade do app) entra em modo somente-leitura em vez de migrar
para trás.

## Alternatives

| Alternativa | Por que não |
|---|---|
| **`ConfigFile` do Godot** | Bom para settings simples, ruim para estruturas aninhadas e migração |
| **Binário com `store_var`** | Frágil entre versões da engine; ilegível para suporte e depuração |
| **SQLite** | Robusto, mas peso e complexidade desproporcionais ao volume (poucos KB) |
| **Save criptografado/ofuscado** | Falsa sensação de segurança: a fonte de verdade competitiva é o servidor. Custa suporte e depuração; a segurança real está em `backend/anti-cheat.md` |
| **Sem versionamento** | Garante quebra na primeira mudança de schema |

## Consequences

**Positivas:** depuração e suporte triviais; migrações testáveis com fixtures reais; resiliência
a queda de energia; caminho natural para cloud save (o blob já é serializável).

**Negativas / mitigações:**
- Save local é editável por usuário avançado → aceito conscientemente: valor competitivo é
  validado no servidor; leaderboards locais são só do próprio jogador.
- Toda mudança de schema exige migração + fixture → é o preço de nunca perder progresso;
  o CI recusa bump de schema sem fixture.

**Compromissos:** salvar em `NOTIFICATION_APPLICATION_PAUSED`, fim de partida, mudança de
settings e a cada 60 s com escrita coalescida — nunca por frame.

## Status

**Accepted** — 2026-08-24. Detalhamento em `docs/architecture/save-system.md`.
