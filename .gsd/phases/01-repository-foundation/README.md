# GSD 01 — Repository Foundation

**Status:** ⬜ pendente
**Depende de:** GSD 00
**Branch:** `feature/gsd-01-repository-foundation`
**Tarefas:** 12 · **Prefixo de ID:** `REPO`

## Objetivo

> Um projeto vazio, mas **de verdade**: abre no Godot, roda no celular, tem CI verde, tem
> testes rodando, tem configuração orientada a dados e tem as convenções sendo verificadas
> por máquina — não por boa vontade.

## Por que esta fase existe

Todo atrito que não for resolvido agora será pago 25 vezes. Se o CI não roda testes na fase 01,
ninguém vai escrever teste na fase 03. Se a checagem de camadas não existe agora, a arquitetura
vira sugestão na fase 07.

## Escopo

**Entra:**
- Projeto Godot 4.3 em `apps/mobile`, com versão pinada e renderer configurado
- Estrutura de pastas de `src/` conforme `docs/architecture/overview.md`
- `core/`: bootstrap, event bus, config service, logging, save service (esqueleto), registry de serviços, `Build` (debug/release)
- GUT instalado e rodando headless
- Scripts em `tools/ci` e `tools/dev` — todos executáveis localmente
- GitHub Actions: `validate.yml`, `client-ci.yml`
- Verificadores automáticos: camadas, nomes de arquivo proibidos, TODO sem tarefa, mock sem fase, placeholder vencido, links quebrados nos docs
- Export presets gerados por script; build de debug Android validado em dispositivo
- Cena principal mínima que prova o pipeline (fundo, texto de versão, FPS)

**NÃO entra:**
- Qualquer mecânica de jogo (Runner, grid, Arc — isso é 02 e 03)
- Design system e telas (é 07)
- Arte (é 08)
- Backend (é 15)

## Resultado esperado

```text
godot --path apps/mobile             abre e roda
./tools/ci/lint.sh                   verde
./tools/ci/test-client.sh            verde (testes de exemplo + save + config)
./tools/ci/validate-repo.sh          verde
./tools/ci/build_android.sh debug    gera APK que instala e roda no aparelho
```

E o CI faz tudo isso sozinho a cada push.
