# GSD 01 — Tarefas

Ordem de execução é a ordem da lista. Cada tarefa termina com commit semântico próprio.

---

### REPO-001 — Criar o projeto Godot e pinar a engine

**Objetivo:** ter `apps/mobile` abrindo no Godot 4.3 com as configurações corretas de mobile.
**Contexto:** ADR-0001 pinou a versão; ADR-0014 define o tick fixo; ADR-0009 define o stretch.
**Dependências:** nenhuma.
**Arquivos:** `apps/mobile/project.godot`, `.godot-version`, `apps/mobile/.gitignore`.
**Passos:**
1. Verificar a engine disponível e registrar a versão exata em `.godot-version` (`4.3.stable`).
   Confirmar que os export templates da mesma versão estão instalados; se não estiverem,
   documentar o passo de instalação em `docs/mobile/android.md`.
2. Criar o projeto em `apps/mobile` com nome `VOLTA`, versão `0.1.0`.
3. Configurar: renderer `mobile`; `display/window/size` 1080×1920; stretch `canvas_items`/`expand`;
   orientação `portrait`; `physics/common/physics_ticks_per_second = 60`;
   `max_physics_steps_per_frame = 4`.
4. Configurar `application/config/features` para 4.3 + Mobile.
5. Criar a estrutura vazia de `src/` conforme `docs/architecture/overview.md` §8, com um
   `README.md` curto por pasta dizendo o que mora ali e em qual fase é preenchida.
**Testes:** `godot --headless --path apps/mobile --check-only` sem erro; projeto abre no editor.
**DoD:** projeto abre; versão pinada; estrutura criada; nenhum warning; commit
`build(client): scaffold godot project targeting mobile`.

---

### REPO-002 — `Build` e flags de ambiente

**Objetivo:** distinguir debug de release em um único lugar, e garantir que ferramentas de
debug não vazem para produção.
**Contexto:** requisito recorrente de todas as fases; o CI de release depende disso.
**Dependências:** REPO-001.
**Arquivos:** `src/core/build.gd`, `src/core/build_flags.gd`.
**Passos:**
1. `Build.is_debug()` usando `OS.is_debug_build()` combinado com a variável `VOLTA_DEBUG_TOOLS`
   lida de um `Resource` gerado no build.
2. `Build.version()`, `Build.commit()`, `Build.env()` (development/staging/production).
3. Convenção documentada: **todo** código de debug fica atrás de `if Build.is_debug():`.
**Testes:** unitário verificando que `is_debug()` é `false` quando a flag de release está ativa.
**DoD:** um único ponto de verdade sobre o tipo de build; documentado em
`docs/architecture/debug-tools.md`.

---

### REPO-003 — Logging estruturado

**Objetivo:** `Log` com categorias e níveis, sem custo quando desligado.
**Dependências:** REPO-002.
**Arquivos:** `src/core/log/log.gd`, `log_category.gd`, `log_sink.gd`, `file_log_sink.gd`.
**Passos:**
1. Enum de categorias (GAMEPLAY, TERRITORY, AI, INPUT, UI, SAVE, NETWORK, AUDIO, PERFORMANCE, ERROR).
2. Níveis DEBUG/INFO/WARN/ERROR, com `Log.enabled(cat, lvl)` verificado **antes** de montar
   qualquer dicionário.
3. Sinks: console e arquivo (`user://logs/`, rotação 5 × 2 MB).
4. `DEBUG` removido em release via `Build.is_debug()`.
**Testes:** unitário — mensagem suprimida não aloca; rotação de arquivo funciona; nível
respeitado por categoria.
**DoD:** conforme `docs/architecture/logging.md`; nenhuma chamada de log no caminho quente
ainda existe (nada de gameplay nesta fase).

---

### REPO-004 — `ServiceRegistry` e `Bootstrap`

**Objetivo:** montar o grafo de serviços em ordem determinística, sem singleton mágico.
**Dependências:** REPO-003.
**Arquivos:** `src/core/service_registry.gd`, `src/core/bootstrap.gd`, `scenes/boot.tscn`.
**Passos:**
1. `ServiceRegistry.register(name, instance)` / `resolve(name)` com erro claro e tipado quando
   o serviço não existe.
2. `Bootstrap` como cena inicial: inicializa `Log` → `ConfigService` → `SaveService` →
   demais serviços → carrega a próxima cena.
3. Ordem e falhas logadas como `INFO`/`ERROR`; falha de serviço não essencial não impede o boot.
4. Autoloads: no máximo `Bootstrap` e `Log`.
**Testes:** integração — boot completo com serviços falsos; resolução de serviço ausente falha
com mensagem útil; ordem de inicialização é estável.
**DoD:** nenhum `Global.` no projeto; ordem determinística; documentado em
`docs/architecture/overview.md` §4.

---

### REPO-005 — `ConfigService` e configuração orientada a dados

**Objetivo:** carregar e **validar** os `.tres` de configuração.
**Contexto:** `docs/architecture/configuration.md`; `docs/design/balance.md` é a fonte dos valores.
**Dependências:** REPO-004.
**Arquivos:** `src/core/config/config_service.gd`, `config_validator.gd`,
`packages/shared/config/balance/*.tres`, `tools/dev/sync_config.sh`.
**Passos:**
1. Criar as classes de `Resource` de balance (`RunnerBalance`, `TerritoryBalance`,
   `ScoreBalance`, `SurgeBalance`, `CameraBalance`, `BackwashBalance`) com `@export` tipado e
   faixa mínima/máxima declarada.
2. Preencher os `.tres` com os valores 🎯 de `docs/design/balance.md`.
3. `ConfigService` carrega no boot, valida faixas e coerência; em debug falha alto, em release
   cai no embutido e loga `ERROR`.
4. `sync_config.sh` copia `packages/shared/config` → `apps/mobile/resources/config` e o CI
   verifica que estão sincronizados.
**Testes:** unitário — config válida carrega; valor fora de faixa é detectado; campo ausente é
detectado; acesso é tipado (sem `get("string")`).
**DoD:** nenhum número de gameplay no código; `balance.md` e os `.tres` batem valor a valor.

---

### REPO-006 — Instalar e configurar o GUT

**Objetivo:** poder escrever e rodar testes desde o primeiro dia.
**Contexto:** ADR-0013.
**Dependências:** REPO-001.
**Arquivos:** `apps/mobile/addons/gut/`, `apps/mobile/tests/`, `tools/ci/test-client.sh`.
**Passos:**
1. Instalar o GUT com versão pinada, isolado em `addons/`.
2. Estrutura `tests/unit`, `tests/integration`, `tests/gameplay` com um teste de exemplo em cada.
3. `test-client.sh` roda headless e propaga o código de saída.
4. Garantir que `addons/gut` seja excluído do export de release.
**Testes:** um teste que passa e um que falha propositalmente (removido depois de validar o
código de saída).
**DoD:** `./tools/ci/test-client.sh` verde; falha de teste derruba o script.

---

### REPO-007 — `SaveService`

**Objetivo:** persistência confiável desde o começo (RISK-009).
**Contexto:** ADR-0003; `docs/architecture/save-system.md`.
**Dependências:** REPO-004.
**Arquivos:** `src/core/save/save_service.gd`, `save_data.gd`, `save_migration.gd`,
`file_save_service.gd`, `tests/unit/test_save_service.gd`.
**Passos:**
1. Estrutura de dados com `meta.schema_version = 1` e os blocos definidos no documento.
2. Escrita atômica: tmp → flush → backup → rename.
3. Carga com recuperação: inválido → `.bak` → recriação preservando os arquivos como `.corrupt-*`.
4. Cadeia de migrações (vazia agora, mas com a mecânica pronta e testada com uma migração fake).
5. Escrita coalescida: `mark_dirty()` + flush em fim de partida, mudança de settings,
   `NOTIFICATION_APPLICATION_PAUSED` e a cada 60 s.
6. `settings.json` separado de `profile.json`.
**Testes:** round-trip; escrita interrompida (simulada); JSON corrompido → backup; backup também
corrompido → recriação sem apagar nada; migração fake 1→2; campo desconhecido preservado.
**DoD:** 6 testes verdes; nenhum consumidor conhece o caminho do arquivo.

---

### REPO-008 — EventBus

**Objetivo:** eventos globais de baixa frequência, com uso disciplinado.
**Dependências:** REPO-004.
**Arquivos:** `src/core/event_bus.gd`, `src/core/events/*.gd`.
**Passos:**
1. Sinais tipados declarados explicitamente (nada de `emit("string_qualquer")`).
2. Documentar na própria classe: **proibido** evento por frame.
3. Em debug, contador de emissões por evento, exposto no futuro menu de debug — para flagrar
   abuso cedo.
**Testes:** unitário de emissão/assinatura; teste que falha se um evento passar de N emissões
por segundo em debug.
**DoD:** conforme `docs/architecture/overview.md` §3.

---

### REPO-009 — Verificadores de arquitetura e repositório

**Objetivo:** transformar as regras de `CONTRIBUTING.md` em falha de CI.
**Contexto:** sem isso, todas as regras deste projeto são decorativas.
**Dependências:** REPO-006.
**Arquivos:** `tools/ci/validate-repo.sh`, `tools/ci/check_layering.gd`, `tools/ci/check_links.sh`.
**Passos:**
1. Nomes de arquivo proibidos (`utils.gd`, `helpers.gd`, `manager.gd`, `global.gd`, `misc.gd`, `common.gd`).
2. `TODO` sem `(GSD-XX/TASK-YYY)`.
3. Bloco `## MOCK` sem `Replacement Phase` e `Replacement Task`.
4. `PLACEHOLDER-*` sem `Replacement: GSD XX`, ou cuja fase de destino já passou.
5. Violação de camadas: `territory/`, `runner/`, `ai/`, `gameplay/` não podem referenciar
   `presentation/` nem `ui/`.
6. Arquivo com mais de 600 linhas; função com mais de 50 linhas (aviso a partir de 400/50).
7. Links quebrados em `docs/` e `.gsd/`.
8. Sincronia entre `packages/shared/config` e `apps/mobile/resources/config`.
**Testes:** casos plantados para cada regra, verificando que o script **falha** quando deve
(teste negativo é o que importa aqui).
**DoD:** script roda em < 10 s; usado pelo CI e localmente; documentado em `CONTRIBUTING.md`.

---

### REPO-010 — Lint e formatação

**Objetivo:** estilo consistente sem discussão em PR.
**Dependências:** REPO-006.
**Arquivos:** `tools/ci/lint.sh`, `.gdlintrc` (ou equivalente), `.editorconfig` (já existe).
**Passos:**
1. Configurar linter de GDScript (indentação com tab, ordem de declarações, nomes,
   **tipagem obrigatória**).
2. Checagem de markdown (links, títulos, largura de linha) para `docs/` e `.gsd/`.
3. `lint.sh` reúne tudo e retorna código de saída correto.
**Testes:** arquivo mal formatado e arquivo sem tipagem fazem o lint falhar.
**DoD:** `./tools/ci/lint.sh` verde no repositório inteiro.

---

### REPO-011 — CI no GitHub Actions

**Objetivo:** tudo acima rodando sozinho em todo push e PR.
**Dependências:** REPO-009, REPO-010.
**Arquivos:** `.github/workflows/validate.yml`, `client-ci.yml`, `tools/ci/setup_godot.sh`.
**Passos:**
1. `setup_godot.sh` baixa a versão de `.godot-version` (editor + export templates) com cache.
2. `validate.yml`: `validate-repo.sh` + lint de docs. Roda em todo push.
3. `client-ci.yml`: import de assets, lint, `check_layering`, testes GUT.
4. Badges no README.
5. Gate de merge: os dois workflows obrigatórios.
**Testes:** um PR de teste com erro proposital precisa ser reprovado pelo CI.
**DoD:** CI verde em `main` e `develop`; tempo total < 8 min; nada exclusivo do runner.

---

### REPO-012 — Cena principal mínima e build Android de debug

**Objetivo:** provar o pipeline inteiro em um aparelho real.
**Contexto:** é aqui que se descobre problema de export — não na GSD 21.
**Dependências:** REPO-001..011.
**Arquivos:** `scenes/boot.tscn`, `scenes/main.tscn`, `src/core/dev_overlay.gd`,
`tools/ci/make_export_presets.sh`, `tools/ci/build_android.sh`.
**Passos:**
1. Cena principal: fundo com a cor `bg.deep` provisória, nome e versão do app, FPS e tier de
   dispositivo detectado. `PLACEHOLDER-ART-006 / Replacement: GSD 08`.
2. Overlay de FPS/memória atrás de `Build.is_debug()`.
3. `make_export_presets.sh` gera `export_presets.cfg` a partir de template + variáveis de
   ambiente (o arquivo continua fora do versionamento).
4. `build_android.sh debug` exporta APK.
5. Instalar e rodar num aparelho Android real; medir cold start e FPS.
6. Registrar o resultado em `docs/performance/device-results.md` (criar o arquivo).
**Testes:** APK instala, abre, mostra a versão correta, roda a 60 FPS; safe area respeitada
mesmo nesta tela mínima.
**DoD:** APK rodando no aparelho; cold start < 1,5 s; primeira linha de `device-results.md`
preenchida; screenshot anexado ao PR.
