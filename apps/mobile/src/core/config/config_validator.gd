class_name ConfigValidator
extends RefCounted

## Validação de configuração (docs/architecture/configuration.md §2). Duas camadas:
## validate() checa faixa por campo via introspecção de @export_range; validate_coherence()
## checa regras que cruzam arquivos e que nenhuma faixa isolada consegue capturar.

## Retorna um Array de Strings com os nomes dos campos inválidos (vazio = válido).
static func validate(resource: Resource) -> Array[String]:
	var invalid: Array[String] = []
	for prop in resource.get_property_list():
		if not (prop.get("usage", 0) & PROPERTY_USAGE_SCRIPT_VARIABLE):
			continue
		if prop.get("hint", PROPERTY_HINT_NONE) != PROPERTY_HINT_RANGE:
			continue
		var parts := String(prop["hint_string"]).split(",")
		if parts.size() < 2:
			continue
		var min_v := float(parts[0])
		var max_v := float(parts[1])
		var value: Variant = resource.get(prop["name"])
		if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
			continue
		if float(value) < min_v or float(value) > max_v:
			invalid.append(String(prop["name"]))
	return invalid


## Coerência entre arquivos (configuration.md §2). Retorna os campos incoerentes (vazio = ok).
static func validate_coherence(runner: RunnerBalance, territory: TerritoryBalance, camera: CameraBalance) -> Array[String]:
	var incoherent: Array[String] = []
	var smallest_area: int = territory.grid_small_width * territory.grid_small_height
	if runner.arc_max_cells >= smallest_area:
		incoherent.append("arc_max_cells")
	var smallest_side: int = mini(territory.grid_small_width, territory.grid_small_height)
	if territory.spawn_min_distance >= smallest_side:
		incoherent.append("spawn_min_distance")
	if camera.zoom_min > camera.zoom_base or camera.zoom_base > camera.zoom_max:
		incoherent.append("zoom_base")
	return incoherent
