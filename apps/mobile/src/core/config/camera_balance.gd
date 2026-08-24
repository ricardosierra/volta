class_name CameraBalance
extends Resource

## Contrato tipado dos parâmetros de Câmera (docs/design/balance.md §11). Os defaults abaixo
## SÃO os valores 🎯 do documento — não arredondados.

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
