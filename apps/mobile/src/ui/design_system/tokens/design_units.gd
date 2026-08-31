class_name DesignUnits
extends RefCounted

## Converte dp (docs/ui/design-system.md §1) em unidades da viewport base do projeto.
##
## A tabela de tipografia e a escala de espaçamento do design system estão em **dp**, a
## unidade física: 16 dp de corpo de texto tem o mesmo tamanho aparente em qualquer
## aparelho. A viewport base do projeto tem 1080 unidades de largura e o telefone de
## referência tem 390 dp — logo 1 dp = 2,77 unidades. Escrever `font_size = 16` num Control
## produz 5,8 dp na tela, ilegível a meio metro do rosto. Toda medida de UI passa por aqui.

const REFERENCE_WIDTH_DP: float = 390.0
const FALLBACK_VIEWPORT_WIDTH: float = 1080.0


static func base_viewport_width() -> float:
	var configured: float = float(ProjectSettings.get_setting("display/window/size/viewport_width", 0))
	if configured <= 0.0:
		return FALLBACK_VIEWPORT_WIDTH
	return configured


static func units_per_dp() -> float:
	return base_viewport_width() / REFERENCE_WIDTH_DP


static func to_units(dp: float) -> float:
	return dp * units_per_dp()


static func to_int_units(dp: float) -> int:
	return int(round(to_units(dp)))


static func to_size(dp_x: float, dp_y: float) -> Vector2:
	return Vector2(to_units(dp_x), to_units(dp_y))
