class_name TypeScale
extends Resource

## Escala tipográfica de docs/ui/design-system.md §1, em **dp**. `ui_scale` é o multiplicador
## de Settings > Display > UI Scale (0,9 · 1,0 · 1,1 · 1,25); ele multiplica o token, nunca
## estica bitmap.

enum Role { DISPLAY, TITLE, HEADING, BODY, LABEL, CAPTION, HUD }

@export_group("Sizes (dp)")
@export var display: float = 48.0
@export var title: float = 32.0
@export var heading: float = 24.0
@export var body: float = 16.0
@export var label: float = 14.0
@export var caption: float = 12.0
@export var hud: float = 20.0

@export_group("Scale")
@export_range(0.9, 1.25) var ui_scale: float = 1.0


func dp_for(role: Role) -> float:
	match role:
		Role.DISPLAY:
			return display
		Role.TITLE:
			return title
		Role.HEADING:
			return heading
		Role.BODY:
			return body
		Role.LABEL:
			return label
		Role.CAPTION:
			return caption
		Role.HUD:
			return hud
		_:
			return body


## Tamanho de fonte pronto para add_theme_font_size_override, já em unidades da viewport.
func font_size(role: Role) -> int:
	return DesignUnits.to_int_units(dp_for(role) * ui_scale)
