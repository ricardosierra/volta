class_name ScoreBalance
extends Resource

## Contrato tipado das constantes de Score (docs/design/balance.md §4). Os defaults abaixo
## SÃO os valores 🎯 do documento — não arredondados.

@export_range(1, 100) var cell_value: int = 4
@export_range(1.0, 5.0) var stolen_cell_mult: float = 1.6
@export_range(10.0, 1000.0) var risk_divisor: float = 150.0
@export_range(1.0, 5.0) var risk_cap: float = 1.5
@export_range(0, 5000) var break_base: int = 600
@export_range(0, 5000) var break_streak_step: int = 300
@export_range(1, 20) var break_streak_cap: int = 5
@export_range(0, 100) var survival_per_second: int = 5
@export_range(0, 50000) var territory_weight: int = 8000
@export_range(0, 50000) var largest_seal_weight: int = 4000
@export_range(0, 10000) var placement_bonus_1st: int = 2500
@export_range(0, 10000) var placement_bonus_2nd: int = 1200
@export_range(0, 10000) var placement_bonus_3rd: int = 600
@export_range(0, 10000) var placement_bonus_other: int = 0
@export_range(1.0, 3.0) var victory_mult: float = 1.25
@export_range(1.0, 3.0) var push_mult: float = 1.25
