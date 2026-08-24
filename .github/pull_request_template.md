## O que muda

<!-- Uma frase. Se for uma fase GSD, cole aqui o resumo do HANDOFF.md. -->

## Fase / tarefas

- Fase: `GSD XX — Nome`
- Tarefas: `PREFIXO-001`, `PREFIXO-002`, …

## Checklist

```text
[ ] ./tools/ci/validate-repo.sh verde
[ ] ./tools/ci/lint.sh verde
[ ] ./tools/ci/test-client.sh verde
[ ] documentação atualizada (docs/ e .gsd/)
[ ] nenhum TODO sem (GSD-XX/TASK-YYY)
[ ] nenhum mock sem Replacement Phase/Task
[ ] nenhum placeholder além da fase de destino
[ ] arquitetura respeitada (camadas, tipagem, sem arquivo-depósito)
[ ] nenhum número de gameplay fora de .tres
[ ] performance medida (se tocou o caminho quente): antes/depois
[ ] .gsd/STATUS.md atualizado
```

## Se tem representação visual

```text
[ ] alinhamento e espaçamento por tokens
[ ] feedback em < 100 ms
[ ] contraste verificado
[ ] responsivo de 16:9 a 20:9 + tablet
[ ] safe area respeitada
```

## Se é uma interação principal (os 7 canais)

```text
[ ] Gameplay  [ ] Animation  [ ] VFX  [ ] SFX  [ ] Haptics  [ ] Camera  [ ] UI Feedback
```

## Evidência

<!-- Capturas, vídeo, números de benchmark, relatório de simulação. -->
