# CI/CD

GitHub Actions. Todo workflow é reproduzível localmente por um script em `tools/ci/` — se só
roda no CI, é armadilha.

## Workflows

| Workflow | Gatilho | Faz |
|---|---|---|
| `validate.yml` | todo push e PR | estrutura do repo, TODOs sem tarefa, mocks órfãos, placeholders vencidos, lint de docs e de links |
| `client-ci.yml` | PR e push que toca `apps/mobile` | lint GDScript, checagem de camadas, testes GUT, 20 partidas headless |
| `client-nightly.yml` | diário 03:00 UTC | 2 000 partidas, benchmarks de território, build de validação Android |
| `api-ci.yml` | PR e push que toca `services/api` | Pint, PHPStan, Pest com Postgres+Redis de serviço |
| `build-android.yml` | tag `v*` ou manual | AAB assinado, artefato, notas de release |
| `build-ios.yml` | tag `v*` ou manual (macOS) | arquivo Xcode, IPA, upload TestFlight |
| `release.yml` | tag `v*` | valida checklist, publica release no GitHub com o CHANGELOG da versão |

## Godot no CI

Versão pinada em `.godot-version` (fonte única). O workflow baixa o mesmo build para editor e
export templates, com cache. Divergência entre a versão local e a do CI é erro, não aviso.

```yaml
- run: |
    GODOT_VERSION=$(cat .godot-version)
    ./tools/ci/setup_godot.sh "$GODOT_VERSION"
    godot --headless --path apps/mobile --import        # importa assets
    ./tools/ci/test-client.sh
```

## Gates de merge

Um PR só entra em `develop` com:

```text
[ ] validate.yml verde
[ ] client-ci.yml (ou api-ci.yml) verde
[ ] sem regressão de performance > 10 %
[ ] quality gate da fase marcado (quando o PR fecha uma fase)
[ ] revisão aprovada
```

## Secrets

| Secret | Uso |
|---|---|
| `ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | assinatura |
| `IOS_CERT_P12`, `IOS_CERT_PASSWORD`, `IOS_PROVISIONING_PROFILE`, `APPLE_API_KEY` | assinatura e TestFlight |
| `API_DEPLOY_KEY` | deploy do backend |

Nenhum secret é impresso em log. Workflows de PR vindos de fork **não** têm acesso a secrets.

## Artefatos

Build de PR guarda: relatório de testes, relatório de benchmark, relatório de simulação e,
quando aplicável, o APK de debug — retenção de 14 dias.
