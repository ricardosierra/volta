class_name StyleKit
extends RefCounted

## Fábrica de StyleBox a partir dos papéis do tema. Elevação vem de brilho e contraste, não
## de sombra difusa (docs/ui/design-system.md §1 "Elevação") — por isso `raised` é borda de
## 1 dp mais um halo curto, nunca um drop shadow.

static func flat(palette: ThemePalette, fill: Color, radius_dp: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	_apply_radius(box, palette, radius_dp)
	return box


static func surface(palette: ThemePalette, radius_dp: int = -1) -> StyleBoxFlat:
	var radius: int = palette.radius_md if radius_dp < 0 else radius_dp
	var box := flat(palette, palette.surface, radius)
	box.border_color = palette.tint(palette.text_main, 0.07)
	_apply_border(box, palette, palette.raised_border_dp)
	return box


static func raised(palette: ThemePalette, accent: Color, radius_dp: int = -1) -> StyleBoxFlat:
	var radius: int = palette.radius_md if radius_dp < 0 else radius_dp
	var box := flat(palette, palette.surface, radius)
	box.border_color = palette.tint(accent, 0.35)
	_apply_border(box, palette, palette.raised_border_dp)
	box.shadow_color = palette.tint(accent, 0.28)
	box.shadow_size = DesignUnits.to_int_units(palette.raised_glow_dp)
	return box


static func outline(palette: ThemePalette, line: Color, radius_dp: int = -1) -> StyleBoxFlat:
	var radius: int = palette.radius_md if radius_dp < 0 else radius_dp
	var box := flat(palette, Color(0, 0, 0, 0), radius)
	box.border_color = line
	_apply_border(box, palette, palette.raised_border_dp)
	return box


static func pill(palette: ThemePalette, fill: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	var radius: int = DesignUnits.to_int_units(999.0)
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	return box


static func empty() -> StyleBoxEmpty:
	return StyleBoxEmpty.new()


static func _apply_radius(box: StyleBoxFlat, palette: ThemePalette, radius_dp: int) -> void:
	var radius: int = palette.radius_units(radius_dp)
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius


static func _apply_border(box: StyleBoxFlat, _palette: ThemePalette, width_dp: float) -> void:
	var width: int = maxi(1, DesignUnits.to_int_units(width_dp))
	box.border_width_left = width
	box.border_width_right = width
	box.border_width_top = width
	box.border_width_bottom = width
