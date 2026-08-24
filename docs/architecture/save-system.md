# Sistema de save

> Perder progresso é a forma mais rápida de perder um jogador. O save é tratado como um
> subsistema crítico: versionado, atômico, com backup e com migrações testadas.
>
> Decisão: [`ADR-0003`](../decisions/ADR-0003-save-system.md). Implementado em GSD 01
> (esqueleto) e completado em GSD 10.

## 1. O que persistimos

| Bloco | Conteúdo |
|---|---|
| `settings` | áudio, háptico, controles, qualidade, acessibilidade, idioma |
| `player` | id local (UUID), apelido, avatar, título, moldura |
| `progress` | XP, rank, tutorial, modos desbloqueados |
| `stats` | todas as estatísticas de perfil |
| `records` | melhores scores por modo, maior Seal, maior Surge, sequências |
| `wallet` | Sparks, Prisms (espelho local; a fonte de verdade vira o servidor em GSD 16) |
| `inventory` | cosméticos possuídos e equipados |
| `achievements` | id → progresso e data de desbloqueio |
| `challenges` | desafios ativos, progresso, data de expiração |
| `meta` | `schema_version`, `app_version`, `created_at`, `updated_at`, `device_id` |

**Não** persistimos estado de partida em andamento no v0.1.0 (partidas duram 3 min; retomar
partida é complexidade sem retorno). Registrado como possível feature pós-launch.

## 2. Formato e local

- JSON legível em `user://save/profile.json` (`user://` mapeia para o armazenamento privado
  do app em Android e iOS).
- Legível de propósito: depuração e suporte valem mais que ofuscação, já que a fonte de verdade
  competitiva é o servidor (GSD 15+). Ver `backend/anti-cheat.md`.
- Arquivos: `profile.json`, `profile.json.bak`, `settings.json` (separado — settings nunca
  podem ser perdidas por corrupção de perfil).

## 3. Escrita atômica

```text
1. serializa em memória
2. escreve em profile.json.tmp
3. flush + close
4. copia profile.json → profile.json.bak   (se existir e for válido)
5. renomeia profile.json.tmp → profile.json
```

Renomear é atômico nos dois sistemas de arquivos-alvo. Queda de energia no meio deixa, no
pior caso, o save anterior intacto.

**Quando salvamos:** fim de partida, mudança de settings, compra/desbloqueio, `NOTIFICATION_APPLICATION_PAUSED`
(app indo para background — o momento mais importante no mobile) e a cada 60 s se houver
mudanças pendentes. Nunca a cada frame; escrita é agendada e coalescida.

## 4. Versionamento e migração

```json
{
  "meta": { "schema_version": 1, "app_version": "0.1.0", "updated_at": "2026-08-24T04:00:00Z" }
}
```

```gdscript
class_name SaveMigration
func from_version() -> int
func to_version() -> int
func migrate(data: Dictionary) -> Dictionary
```

- Migrações são **encadeadas**: 1→2→3. Nunca "pula" versão.
- Toda migração tem teste com um fixture real da versão antiga em
  `tests/fixtures/saves/v{n}_profile.json`. Sem fixture, sem merge.
- Save de versão **maior** que a suportada (downgrade do app): não apagamos. Entramos em modo
  somente-leitura, avisamos e mantemos o arquivo intacto.
- Campo desconhecido em versão conhecida é **preservado** no round-trip (proteção contra perda
  em builds de teste).

## 5. Recuperação de corrupção

```text
carregar profile.json
  ├─ JSON inválido ou checksum quebrado → tenta profile.json.bak
  │     ├─ ok  → restaura, avisa o jogador discretamente, salva de novo
  │     └─ ruim → cria perfil novo, preserva os dois arquivos como .corrupt-<timestamp>
  └─ ok → segue
```

Nunca apagamos silenciosamente o save do jogador. Arquivo suspeito é **renomeado**, não deletado.

## 6. Interface

```gdscript
class_name SaveService
func load_profile() -> SaveResult          # ok | restored_from_backup | recreated
func save_profile(now: bool = false) -> void
func mark_dirty(section: StringName) -> void
func export_blob() -> PackedByteArray      # para cloud save (GSD 16)
func import_blob(blob: PackedByteArray) -> ImportResult
```

Consumidores nunca escrevem no disco direto. Ninguém fora de `core/save` conhece o caminho
do arquivo.

## 7. Cloud save (GSD 16)

- Fonte de verdade: **servidor**, para carteira, inventário e progressão.
- Resolução de conflito: maior `updated_at` vence para settings; para progresso, o servidor
  reconcilia por **soma monotônica** (XP e conquistas nunca diminuem).
- Offline continua funcionando integralmente; a sincronização é oportunista.

## 8. Testes obrigatórios

| Teste | Fase |
|---|---|
| round-trip de todos os blocos | 01 |
| escrita atômica interrompida (simulada) | 01 |
| carga de save corrompido → backup | 01 |
| carga de save corrompido + backup ruim → recriação preservando arquivos | 01 |
| migração v1→v2 com fixture real | a cada bump |
| save de versão futura → somente leitura | 10 |
| 500 ciclos de save/load sem crescimento de memória | 19 |
