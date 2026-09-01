class_name ThemeService
extends RefCounted

## Resolve o tema ativo e entrega papéis prontos para os componentes (docs/ui/design-system.md).
## Registrado pelo Bootstrap e injetado pela ScreenStack em cada Screen — nenhum singleton
## mágico, nenhum componente lendo hex.

const THEME_DIR: String = "res://resources/themes/"
const DEFAULT_THEME: String = "neon"

## Figuras tabulares: o número da HUD não pode fazer o layout tremer ao mudar
## (docs/ui/hud.md regra 1).
const TABULAR_FEATURES: Dictionary = {"tnum": 1, "lnum": 1}

var _palette: ThemePalette
var _type_scale: TypeScale
var _base_font: Font
var _tabular_font: Font
var _theme_id: String = ""
var _last_error: String = ""


func load_theme(theme_id: String = DEFAULT_THEME) -> bool:
	var palette_path: String = THEME_DIR + theme_id + ".tres"
	var loaded: Resource = load(palette_path)
	if loaded is ThemePalette:
		_palette = loaded
		_theme_id = theme_id
	else:
		_last_error = "theme_not_found:%s" % theme_id
		push_error("ThemeService: tema '%s' inválido em %s" % [theme_id, palette_path])
		_palette = ThemePalette.new()
		_theme_id = DEFAULT_THEME

	_load_type_scale()
	_load_fonts()
	return _last_error == ""


func palette() -> ThemePalette:
	if _palette == null:
		load_theme()
	return _palette


func type_scale() -> TypeScale:
	if _type_scale == null:
		load_theme()
	return _type_scale


func theme_id() -> String:
	return _theme_id


func get_last_error() -> String:
	return _last_error


func font_size(role: TypeScale.Role) -> int:
	return type_scale().font_size(role)


func set_ui_scale(scale: float) -> void:
	type_scale().ui_scale = clampf(scale, 0.9, 1.25)


## Fonte de texto corrido.
func font() -> Font:
	return _base_font


## Fonte de números — mesma família, figuras de largura fixa.
func tabular_font() -> Font:
	return _tabular_font


func _load_type_scale() -> void:
	var loaded: Resource = load(THEME_DIR + "type_scale.tres")
	if loaded is TypeScale:
		_type_scale = loaded
	else:
		_type_scale = TypeScale.new()


func _load_fonts() -> void:
	# PLACEHOLDER-ART-004: família geométrica definitiva ainda não vendorizada. Replacement: GSD 08
	# Até lá, a SystemFont do projeto, que já tem latim estendido.
	var loaded: Resource = load(THEME_DIR + "typography.tres")
	if loaded is Font:
		_base_font = loaded
	else:
		_base_font = SystemFont.new()

	var variation := FontVariation.new()
	variation.base_font = _base_font
	variation.opentype_features = TABULAR_FEATURES
	_tabular_font = variation
