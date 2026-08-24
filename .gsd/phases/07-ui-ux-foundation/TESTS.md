# GSD 07 — Testes

## Unit
`test_tokens.gd` (carga, troca de tema, token ausente) · `test_screen_stack.gd` (push/pop,
back, confirmação na raiz) · `test_settings_persistence.gd` (cada opção salva e restaura) ·
`test_tutorial_director.gd` (gatilhos, condições de saída, progresso) ·
`test_i18n.gd` (chave faltando, chave órfã, fallback)

## Integration
`test_navigation_flow.gd` (todo o mapa de navegação) · `test_first_run.gd` (primeira execução
vai direto para a partida) · `test_settings_effect.gd` (mudar controle afeta o input de fato) ·
`test_pause_resume_state.gd` (estado da tela sobrevive ao ciclo do sistema)

## Automatizados de layout
`screenshot_matrix.sh` gera capturas de todas as telas × 6 formatos × 2 escalas, anexadas ao PR.
Script de contraste roda sobre os tokens de todos os temas.

## Manual
```text
[ ] navegação nunca deixa o jogador perdido
[ ] back/gesto se comportam nos dois sistemas
[ ] test drive de controles responde ao vivo
[ ] onboarding não atrapalha quem já sabe jogar
[ ] nenhuma tela demora sem mostrar algo
[ ] som e háptico de UI presentes e não irritantes
```

## Playtest
5 pessoas novas: tempo até o 1º Seal, conclusão da 1ª partida, passos concluídos, se iniciaram
a 2ª partida. Metas em `docs/design/onboarding.md`.

## Critério de saída
Testes verdes + capturas da matriz sem quebra + playtest dentro das metas.
