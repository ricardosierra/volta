# GSD 01 — Requisitos

## Funcionais

| # | Requisito | Verificação |
|---|---|---|
| R01-01 | Projeto Godot 4.3 abre sem erro e sem warning | abrir no editor; `godot --headless --check-only` |
| R01-02 | Versão da engine pinada em `.godot-version` e usada pelo CI | arquivo + workflow |
| R01-03 | Renderer `Mobile` configurado, com fallback `Compatibility` documentado | `project.godot` |
| R01-04 | Estrutura de `src/` corresponde à documentada | `tools/ci/validate-repo.sh` |
| R01-05 | `Bootstrap` inicializa serviços em ordem determinística e loga o resultado | teste de integração |
| R01-06 | `ConfigService` carrega `.tres` de `resources/config/` e **valida faixas** | teste unitário com config inválida |
| R01-07 | `Log` funciona por categoria e nível, com desligamento em release | teste unitário |
| R01-08 | `SaveService` faz round-trip, escrita atômica, backup e recuperação | 4 testes unitários |
| R01-09 | `ServiceRegistry` registra e resolve por interface, com erro claro se faltar | teste unitário |
| R01-10 | `Build.is_debug()` distingue debug de release e controla ferramentas de debug | teste + verificação no export |
| R01-11 | GUT roda headless e falha o processo com código de saída ≠ 0 | `./tools/ci/test-client.sh` |
| R01-12 | Cena principal roda a 60 FPS mostrando versão e FPS | execução em dispositivo |
| R01-13 | Export Android de debug gera APK instalável | build + instalação real |
| R01-14 | CI executa lint, validação e testes em todo push e PR | Actions verde |
| R01-15 | `validate-repo.sh` detecta: arquivo-depósito, TODO sem tarefa, mock sem fase, placeholder vencido, violação de camada, link quebrado | testes negativos com casos plantados |
| R01-16 | `.tres` de configuração vivem em `packages/shared/config` e são sincronizados para o projeto | script + verificação de CI |

## Não funcionais

| # | Requisito |
|---|---|
| N01-01 | Todo script de CI roda igual localmente (nada exclusivo do runner) |
| N01-02 | Cold start do projeto vazio < 1,5 s no aparelho Mid |
| N01-03 | Todo script GDScript com tipagem estática completa |
| N01-04 | Nenhum autoload além do estritamente necessário (`Bootstrap` e `Log`) |
| N01-05 | Nenhuma dependência de terceiros além do GUT (só em contexto de teste) |
| N01-06 | O CI completo (validate + client-ci) roda em < 8 minutos |
