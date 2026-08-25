# Autoload "Bootstrap" (project.godot). Sem class_name: Godot 4.3 rejeita class_name igual
# ao nome de um autoload ("Parse Error: Class 'Bootstrap' hides an autoload singleton.").
extends Node

## Monta o grafo de serviços em ordem determinística e injeta via ServiceRegistry — sem
## singleton mágico (docs/architecture/overview.md §4). É o segundo e último autoload
## (project.godot); roda boot() sozinho ao entrar na árvore, pois o _ready() de um autoload
## executa antes da cena principal.

signal boot_completed(registry: ServiceRegistry)
signal boot_failed(service_name: String, reason: String)

## Cena carregada ao fim do boot. Vazio nesta fase; o Plano 01-10 troca esta linha para
## "res://scenes/main.tscn" (edição de dado, sem lógica nova).
var next_scene_path: String = "res://scenes/main.tscn"

var registry: ServiceRegistry = ServiceRegistry.new()
var boot_order: Array[String] = []
var _steps: Array[Dictionary] = []


func _ready() -> void:
	configure_steps(_default_steps())
	boot()


func configure_steps(steps: Array[Dictionary]) -> void:
	_steps = steps


func boot() -> void:
	boot_order.clear()
	for step in _steps:
		var service_name: String = step["name"]
		var essential: bool = step.get("essential", true)
		var factory: Callable = step["factory"]
		var instance: Object = factory.call()
		if instance == null:
			var msg := "boot step '%s' retornou null" % service_name
			if Log:
				Log.error(Log.Category.ERROR, "boot_step_failed", {"service": service_name, "essential": essential})
			boot_failed.emit(service_name, msg)
			if essential:
				return
			continue
		registry.register(service_name, instance)
		boot_order.append(service_name)
		if Log:
			Log.info(Log.Category.GAMEPLAY, "boot_step_ok", {"service": service_name})
	boot_completed.emit(registry)
	_load_next_scene()


func _default_steps() -> Array[Dictionary]:
	# Passos concretos de produção (Config, Save, EventBus) são adicionados pelos planos que
	# os implementam (01-04, 01-05, 01-06) chamando configure_steps() com a lista completa
	# antes de boot() — ou, em produção, sobrescrevendo este método. Nesta fase, apenas Log
	# (já vivo como autoload) é re-registrado para lookup consistente via ServiceRegistry.
	return [
		{"name": "log", "essential": true, "factory": func() -> Object: return Log},
	]


func _load_next_scene() -> void:
	if next_scene_path == "" or not is_inside_tree():
		return  # testes instanciam fora da árvore; nada a carregar nesta fase
	get_tree().change_scene_to_file.call_deferred(next_scene_path)
