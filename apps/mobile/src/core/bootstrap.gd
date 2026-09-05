extends Node

signal boot_completed(registry: ServiceRegistry)
signal boot_failed(service_name: String, reason: String)

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
			var reason := "boot step '%s' retornou null" % service_name
			if is_instance_valid(Log):
				Log.error(Log.Category.ERROR, "boot_step_failed", {"service": service_name, "essential": essential})
			boot_failed.emit(service_name, reason)
			if essential:
				return
			continue

		# For nodes, add them to the tree so they can _process
		if instance is Node and not instance.is_inside_tree():
			add_child(instance)

		registry.register(service_name, instance)
		boot_order.append(service_name)
		if is_instance_valid(Log):
			Log.info(Log.Category.GAMEPLAY, "boot_step_ok", {"service": service_name})

	boot_completed.emit(registry)
	_load_next_scene()

func _default_steps() -> Array[Dictionary]:
	return [
		{"name": "config", "factory": func() -> Object: return _make_config_service()},
		{"name": "log", "factory": func(): return Log},
		{"name": "quality", "factory": func(): return QualityService.new()},
		{"name": "haptics", "factory": func(): return HapticService.new()},
		{"name": "vfx", "factory": func(): return VfxService.new()},
		{"name": "wallet", "factory": func(): return Wallet.new()},
		{"name": "catalog", "factory": func(): return Catalog.new()},
		{"name": "profile_repo", "factory": func(): return LocalProfileRepository.new()}
	]

func _make_config_service() -> Object:
	# Factory nomeada (não lambda multilinha) porque um bloco de função com mais de uma
	# instrução dentro de um dicionário aninhado num array literal quebra o parser do
	# GDScript 4.7 ("Unindent doesn't match the previous indentation level") — confirmado
	# com --check-only neste arquivo. svc nunca é null: load_all() cai nos defaults
	# embutidos de RunnerBalance/etc. quando o .tres falha em carregar ou validar.
	var svc := ConfigService.new()
	svc.load_all()
	return svc

func _load_next_scene() -> void:
	if next_scene_path == "" or not is_inside_tree():
		return
	# The autoload is ready before the configured main scene. Defer the comparison until
	# the initial scene has become `current_scene`; otherwise a main.tscn entry point would
	# be loaded a second time on every launch.
	call_deferred("_change_to_next_scene")


func _change_to_next_scene() -> void:
	if next_scene_path == "" or not is_inside_tree():
		return
	var current_scene := get_tree().current_scene
	if current_scene and current_scene.scene_file_path == next_scene_path:
		return
	get_tree().change_scene_to_file(next_scene_path)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		print("iOS App Backgrounded: Forcing Cloud Save sync and pausing game.")
		# Force save logic here
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		print("iOS App Resumed.")
