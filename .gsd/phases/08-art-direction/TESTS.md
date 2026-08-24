# GSD 08 — Testes

## Automatizados
`check_contrast.gd` (4,5:1 texto, 3:1 UI, em todos os temas) · `check_hue_separation.gd`
(≥ 40° entre cores de jogador) · `validate-repo.sh` (nenhum `PLACEHOLDER-ART-*`) ·
`check_texture_budget.sh` (tamanho e resolução) · `check_credits.sh` (todo asset de terceiro
listado)

## Visual (capturas)
Showcase + todas as telas + 3 momentos de partida, para: 8 temas × 3 presets × 2 escalas de UI.
Anexado ao PR. Simulador de daltonismo aplicado a um subconjunto.

## Performance (dispositivo real)
```text
[ ] GPU de VFX < 2,0 ms (Mid, Medium)
[ ] draw calls dentro do teto por preset
[ ] 60 FPS com partida cheia e Mega Seal
[ ] memória de textura <= 24 MB
[ ] preset Low a 60 FPS num aparelho Low real
```

## Manual
```text
[ ] o jogo não parece protótipo
[ ] o Arc comunica risco pelo brilho
[ ] capturar é visualmente satisfatório
[ ] roubo é perceptível
[ ] o fundo não compete com o campo
[ ] Monochrome é jogável
[ ] nenhum efeito esconde ameaça
```

## Playtest
5 pessoas: teste cego de ameaça (≥ 90 %) + teste "parece publicado?" (≥ 4/5).

## Critério de saída
Zero placeholder + verificações automáticas verdes + orçamento de GPU respeitado + os dois
testes com pessoas aprovados.
