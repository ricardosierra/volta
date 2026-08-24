# GSD 01 — Testes

## Unit

| Arquivo | Cobre |
|---|---|
| `test_build.gd` | `is_debug()` em debug e release; versão e commit |
| `test_log.gd` | filtro por categoria e nível; supressão sem alocação; rotação de arquivo |
| `test_service_registry.gd` | registro, resolução, erro em serviço ausente, duplicidade |
| `test_config_service.gd` | carga válida; valor fora de faixa; campo ausente; coerência entre arquivos |
| `test_save_service.gd` | round-trip; escrita atômica interrompida; corrupção → backup; backup ruim → recriação; migração 1→2; campo desconhecido preservado |
| `test_event_bus.gd` | emissão, assinatura, desassinatura, contador em debug |

## Integration

| Arquivo | Cobre |
|---|---|
| `test_bootstrap.gd` | ordem de inicialização; falha de serviço não essencial não derruba o boot; troca de cena ao fim |
| `test_config_sync.gd` | `packages/shared/config` e `apps/mobile/resources/config` idênticos |

## Testes negativos das ferramentas (obrigatórios)

`tests/tools/` com casos plantados que **precisam** fazer `validate-repo.sh` falhar:

```text
[ ] arquivo chamado utils.gd
[ ] TODO sem (GSD-XX/TASK-YYY)
[ ] bloco MOCK sem Replacement Phase
[ ] PLACEHOLDER-ART-999 sem Replacement
[ ] PLACEHOLDER com fase de destino já passada
[ ] import de presentation/ dentro de territory/
[ ] arquivo com 700 linhas
[ ] link quebrado em docs/
```

## Manual / dispositivo

```text
[ ] APK instala em Android real
[ ] app abre em < 1,5 s (cold start)
[ ] 60 FPS estáveis na cena mínima
[ ] versão exibida bate com project.godot
[ ] safe area respeitada (texto não sob o notch)
[ ] rotação bloqueada em portrait
[ ] app vai para background e volta sem erro
```

## Critério de saída

Todos os testes acima verdes, incluindo os negativos. Um verificador que não falha quando deve
é pior que não existir — dá falsa segurança para 24 fases.
