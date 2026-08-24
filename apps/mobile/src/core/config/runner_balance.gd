class_name RunnerBalance
extends Resource

## Contrato tipado dos parâmetros de Runner (docs/design/balance.md §2). Os defaults abaixo
## SÃO os valores 🎯 do documento — não arredondados. O range de cada @export_range é a faixa
## de validação usada por ConfigValidator (introspecção via get_property_list()).

@export_range(50.0, 600.0) var base_speed: float = 220.0
@export_range(90.0, 1080.0) var turn_rate: float = 540.0
@export_range(4.0, 32.0) var collision_radius: float = 10.0
@export_range(2.0, 16.0) var arc_visual_width: float = 6.0
@export_range(0.0, 10.0) var spawn_invuln: float = 2.0
@export_range(0.0, 10.0) var respawn_delay: float = 1.5
@export_range(0.0, 10.0) var respawn_delay_time_attack: float = 3.0
@export_range(100, 5000) var arc_max_cells: int = 1200
@export_range(1.0, 50.0) var overload_decay: float = 8.0
