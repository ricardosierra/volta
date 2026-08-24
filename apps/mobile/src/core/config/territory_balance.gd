class_name TerritoryBalance
extends Resource

## Contrato tipado dos parâmetros de Field/Território (docs/design/balance.md §1). Os defaults
## abaixo SÃO os valores 🎯 do documento — não arredondados.

@export_range(4.0, 64.0) var cell_size: float = 16.0
@export_range(32, 512) var grid_default_width: int = 128
@export_range(32, 512) var grid_default_height: int = 128
@export_range(32, 512) var grid_small_width: int = 96
@export_range(32, 512) var grid_small_height: int = 96
@export_range(32, 512) var grid_large_width: int = 160
@export_range(32, 512) var grid_large_height: int = 160
@export_range(1, 20) var spawn_claim_cells: int = 5
@export_range(1, 200) var spawn_min_distance: int = 28
@export_range(1, 8) var border_thickness: int = 1
