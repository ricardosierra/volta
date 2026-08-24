# GSD 01 — Critérios de aceite

| # | Critério | Como verificar |
|---|---|---|
| A01-01 | `godot --path apps/mobile` abre o projeto sem erro nem warning | manual + `--check-only` no CI |
| A01-02 | A versão da engine está pinada e o CI usa exatamente a mesma | `.godot-version` + log do workflow |
| A01-03 | A estrutura de `src/` corresponde à documentada, com README por pasta | `validate-repo.sh` |
| A01-04 | O boot inicializa os serviços em ordem determinística e loga o resultado | teste de integração + log |
| A01-05 | `ConfigService` carrega os `.tres` e rejeita configuração inválida | 3 testes unitários |
| A01-06 | Os valores dos `.tres` batem com `docs/design/balance.md` | revisão + script de comparação |
| A01-07 | `SaveService` sobrevive a corrupção sem perder dados do jogador | 4 testes unitários |
| A01-08 | `./tools/ci/test-client.sh` roda headless e falha corretamente | executar com um teste quebrado plantado |
| A01-09 | `validate-repo.sh` detecta **todas** as 8 violações que promete | 8 testes negativos |
| A01-10 | `lint.sh` reprova arquivo sem tipagem estática | teste negativo |
| A01-11 | CI verde em push e PR, em menos de 8 minutos | GitHub Actions |
| A01-12 | APK de debug instala e roda num Android real | vídeo/screenshot no PR |
| A01-13 | Cold start < 1,5 s no aparelho de referência | `device-results.md` |
| A01-14 | 60 FPS estáveis na cena mínima | overlay de FPS |
| A01-15 | Nenhum autoload além de `Bootstrap` e `Log` | `project.godot` |
| A01-16 | Nenhum arquivo-depósito e nenhum TODO sem tarefa no repositório | `validate-repo.sh` |
| A01-17 | Toda ferramenta de debug está atrás de `Build.is_debug()` | grep + revisão |

## Demonstração de fim de fase

Gravar um vídeo de 30 segundos mostrando: `lint.sh` → `test-client.sh` → `validate-repo.sh`
verdes no terminal, e o APK rodando no celular com o overlay de FPS. É a prova de que o
pipeline existe de ponta a ponta.
