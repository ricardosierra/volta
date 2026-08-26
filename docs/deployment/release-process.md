# Processo de release

## Versionamento

- O projeto **começa em `v0.1.0`**. Não existe `v1.0.0` no lançamento.
- `v1.0.0` fica reservado para maturidade em produção com base de usuários relevante.
- `minor` = features (`v0.2.0`); `patch` = correções (`v0.1.1`).
- `versionCode` (Android) e `CFBundleVersion` (iOS) são inteiros monotônicos derivados do
  semver: `major*10000 + minor*100 + patch`.

## Fechar uma versão

```bash
git checkout develop && git pull
git checkout -b release/v0.1.0

# 1. bump
#    - apps/mobile/project.godot  (config/version)
#    - CHANGELOG.md               (mover `[Unreleased]` para a seção da versão)
# 2. congelar: só correção de bug entra a partir daqui
# 3. rodar a bateria completa
./tools/ci/lint.sh && ./tools/ci/test-client.sh && ./tools/dev/simulate.sh 2000
./tools/ci/build_android.sh release && ./tools/ci/build_ios.sh

# 4. QA em dispositivos (ver docs/mobile/device-matrix.md)
# 5. merge
git checkout master && git merge --no-ff release/v0.1.0
git tag -a v0.1.0 -m "VOLTA v0.1.0"
git push origin master --tags
git checkout develop && git merge --no-ff master
```

O CHANGELOG segue o formato **Release Notes** deste repositório (`### ✨ Novidades`,
`### 🎨 Melhorias`, `### 🐛 Correções`, `### 🔧 Técnico`, itens em `- [x]`).

## Checklist de release

```text
[ ] 0 bugs blocker · 0 críticos
[ ] Todos os quality gates das fases envolvidas fechados
[ ] Testes verdes (unit, integration, gameplay, stress 2000)
[ ] Benchmarks dentro do orçamento; nenhuma regressão > 10 %
[ ] Migração de save testada a partir de TODAS as versões publicadas
[ ] VOLTA_DEBUG_TOOLS=false; nenhuma cena de debug no export
[ ] Nenhum PLACEHOLDER-ART-* ou MOCK vencido no código
[ ] Nenhum TODO sem referência de tarefa
[ ] Ícones, splash e launch screen corretos em todas as densidades
[ ] Safe area validada nos aparelhos extremos
[ ] Textos revisados em en e pt-BR; nada truncado em UI scale 1,25
[ ] Política de privacidade publicada e ligada na loja
[ ] Data Safety (Play) e Privacy Label (App Store) coerentes com a coleta real
[ ] Analytics validado ponta a ponta em build de produção
[ ] Crash reporting recebendo eventos da build final
[ ] Assets de loja prontos (ícone, screenshots, descrições, vídeo)
[ ] Plano de rollback escrito e ensaiado
[ ] Tag anotada criada e CHANGELOG atualizado
```

## Publicação

| Etapa | Android | iOS |
|---|---|---|
| Teste interno | Internal testing (até 100) | TestFlight interno |
| Teste fechado | Closed testing | TestFlight externo |
| Lançamento gradual | staged rollout 5 % → 20 % → 50 % → 100 % | phased release (7 dias) |
| Monitoramento | crash-free, ANR, avaliações, retenção D1 | crash-free, avaliações |

Nunca 100 % de imediato. Cada degrau exige 24 h de métrica saudável.

## Rollback

| Situação | Ação |
|---|---|
| Crash rate > 2 % | **parar rollout** imediatamente |
| Bug crítico de gameplay | parar rollout + hotfix `patch` |
| Bug de save/perda de progresso | parar rollout + hotfix + comunicação pública |
| Problema de servidor | remote config para desativar a feature afetada, **sem** nova build |

O Play permite halt de rollout; a App Store permite pausar phased release. Ambos são ensaiados
antes do primeiro lançamento — descobrir como parar durante o incêndio é tarde demais.

## Pós-release

- Monitorar 72 h: crash-free, ANR, retenção D1, avaliações, funil de onboarding.
- Responder avaliações da loja na primeira semana.
- Registrar aprendizados em `.gsd/phases/25-post-launch/`.

## Deployment Playbook

## Phased Rollout
- Android: 10% -> 50% -> 100% over 7 days.
- iOS: 7-day phased release.

## Emergency Halts
1. Pause rollout in Google Play / App Store Connect immediately.
2. Toggle the `kill_switch_enabled` flag via Firebase Remote Config (if implemented later) or hardcode API rejection.
3. Push hotfix branch, cut new version.
