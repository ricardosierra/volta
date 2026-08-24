class_name SurgeBalance
extends Resource

## Contrato tipado dos parâmetros de Surge (docs/design/balance.md §5). Os defaults abaixo
## SÃO os valores 🎯 do documento — não arredondados.

@export_range(0.01, 1.0) var surge_step: float = 0.15
@export_range(1, 20) var surge_max_level: int = 6
@export_range(1.0, 30.0) var seal_chain_window: float = 8.0
@export_range(1.0, 30.0) var break_chain_window: float = 10.0
@export_range(1.0, 30.0) var surge_decay_interval: float = 8.0
