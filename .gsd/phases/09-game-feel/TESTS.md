# GSD 09 — Testes

## Unit
`test_vfx_pool.gd` (reuso, esgotamento, limpeza) · `test_haptic_service.gd` (padrões, níveis,
ausência de suporte) · `test_camera_reactions.gd` (limites, escala por configuração, input
preservado) · `test_adaptive_music.gd` (gatilhos de camada, crossfade) ·
`test_accessibility_settings.gd` (cada redução aplicada num único ponto)

## Integration
`test_seal_feedback.gd` (7 canais disparados na captura) · `test_break_feedback.gd` ·
`test_no_input_block.gd` (input lido durante todos os efeitos) ·
`test_audio_pause_resume.gd` (sem estalo, sem dessincronia)

## Performance (dispositivo)
```text
[ ] VFX CPU < 0,7 ms · GPU < 2,0 ms
[ ] áudio < 0,5 ms, <= 16 vozes, latência < 60 ms
[ ] 60 FPS com Mega Seal + Break simultâneos
[ ] zero alocação durante 3 min de partida
```

## Manual
```text
[ ] cada ação principal responde nos 7 canais
[ ] intensidade proporcional
[ ] teste de olhos fechados: identificar 4 eventos só pelo som
[ ] partida completa com todas as reduções de acessibilidade
[ ] 10 min contínuos sem fadiga auditiva
[ ] háptico correto em Android e iOS
```

## Playtest
5 pessoas, nota 1–5 para "capturar é satisfatório". Meta: média ≥ 4,0.

## Critério de saída
Matriz de canais completa + orçamentos respeitados + playtest ≥ 4,0.
