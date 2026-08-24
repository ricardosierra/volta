# packages/shared — contratos compartilhados

O que precisa ser idêntico entre cliente e servidor.

| Pasta | Conteúdo | Fase |
|---|---|---|
| `config/` | `.tres` de balance, modos, arenas, bots, power-ups, economia — **fonte única** | GSD 01 |
| `schemas/` | schema do save e dos payloads da API | GSD 15 |
| `protocol/` | mensagens do multiplayer | GSD 17 |

`config/` é sincronizado para `apps/mobile/resources/config` por `tools/dev/sync_config.sh`;
o CI verifica que os dois estão iguais.
