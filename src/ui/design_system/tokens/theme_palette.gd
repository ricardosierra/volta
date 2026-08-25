class_name ThemePalette
extends Resource

@export_group("Colors")
@export var background: Color = Color("0a0a0c")
@export var surface: Color = Color("141417")
@export var primary: Color = Color("00e5ff")
@export var secondary: Color = Color("ff0055")
@export var text_main: Color = Color("ffffff")
@export var text_muted: Color = Color("888888")
@export var danger: Color = Color("ff3333")

@export_group("Spacing")
@export var space_xs: int = 4
@export var space_sm: int = 8
@export var space_md: int = 16
@export var space_lg: int = 24
@export var space_xl: int = 32

@export_group("Radii")
@export var radius_sm: int = 4
@export var radius_md: int = 8
@export var radius_lg: int = 16
@export var radius_pill: int = 999
