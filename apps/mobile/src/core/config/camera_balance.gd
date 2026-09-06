class_name CameraBalance
extends Resource

## Contrato tipado dos parâmetros de Câmera (docs/design/balance.md §11). Os defaults abaixo
## SÃO os valores 🎯 do documento — não arredondados.

## Quantas células o enquadramento base deve mostrar. balance.md §11 define zoom_base 1,0
## como "mostra ≈ 42 × 24 células em 19,5:9" — esses são os números daquela frase, agora
## explícitos como dado em vez de ficarem só no comentário. A GameCamera converte isso no
## zoom real de Camera2D a partir da área útil medida em execução; sem eles, zoom_base era
## aplicado cru e a câmera mostrava 146 × 67 células num aparelho 2340×1080.
@export_range(10.0, 120.0) var visible_cells_x: float = 42.0
@export_range(10.0, 120.0) var visible_cells_y: float = 24.0

## Multiplicador sobre o enquadramento acima, não um zoom absoluto de engine.
@export_range(0.5, 2.0) var zoom_base: float = 1.0
@export_range(0.3, 2.0) var zoom_min: float = 0.75
@export_range(0.3, 3.0) var zoom_max: float = 1.35
@export_range(1.0, 20.0) var follow_smoothing: float = 8.0
@export_range(0.0, 300.0) var lookahead: float = 90.0
@export_range(0.0, 1.0) var punch_seal_amplitude: float = 0.03
@export_range(0.0, 1.0) var punch_seal_duration: float = 0.12
@export_range(0.0, 1.0) var punch_break_amplitude: float = 0.06
@export_range(0.0, 1.0) var punch_break_duration: float = 0.18
@export_range(0.0, 20.0) var shake_max: float = 4.0
