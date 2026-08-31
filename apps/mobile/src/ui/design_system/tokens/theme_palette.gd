class_name ThemePalette
extends Resource

## Papéis de cor, espaçamento, raio e movimento (docs/ui/design-system.md §1).
## Nenhum componente conhece hex: componentes pedem papéis. Trocar de tema troca este
## recurso inteiro e todo o app acompanha.
##
## Medidas de espaço e raio estão em **dp** — passe por DesignUnits antes de aplicar num
## Control, senão viram unidades da viewport e encolhem 2,77×.

@export_group("Colors")
@export var background: Color = Color("0a0a0c")
@export var surface: Color = Color("141417")
@export var raised: Color = Color("1c1c22")
@export var primary: Color = Color("00e5ff")
@export var secondary: Color = Color("ff0055")
@export var text_main: Color = Color("ffffff")
@export var text_muted: Color = Color("888888")
@export var text_inverse: Color = Color("0a0a0c")
@export var danger: Color = Color("ff3333")
@export var warning: Color = Color("ffb020")
@export var success: Color = Color("00ffa3")

@export_group("Runners")
@export var player_colors: Array[Color] = [
	Color("00e5ff"),
	Color("ff0055"),
	Color("b98cff"),
	Color("9be564"),
	Color("ffb020"),
	Color("ff7ac6"),
	Color("7ad7ff"),
	Color("ffffff")
]

@export_group("Spacing")
@export var space_xs: int = 4
@export var space_sm: int = 8
@export var space_md: int = 16
@export var space_lg: int = 24
@export var space_xl: int = 32
@export var space_2xl: int = 48
@export var space_3xl: int = 64

@export_group("Radii")
@export var radius_sm: int = 4
@export var radius_md: int = 8
@export var radius_lg: int = 16
@export var radius_pill: int = 999

@export_group("Motion")
@export var motion_fast: float = 0.12
@export var motion_base: float = 0.20
@export var motion_slow: float = 0.28
@export var motion_screen: float = 0.25

@export_group("Elevation")
@export var raised_border_dp: float = 1.0
@export var raised_glow_dp: float = 4.0
@export var overlay_dim: float = 0.6


func player_color(runner_id: int) -> Color:
	if player_colors.is_empty():
		return primary
	if runner_id < 0:
		return text_muted
	return player_colors[runner_id % player_colors.size()]


## Mesma cor com alfa trocado — o padrão de preenchimento de território e halo.
func tint(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)


func space_units(dp: int) -> int:
	return DesignUnits.to_int_units(float(dp))


func radius_units(dp: int) -> int:
	if dp >= radius_pill:
		return dp
	return DesignUnits.to_int_units(float(dp))
