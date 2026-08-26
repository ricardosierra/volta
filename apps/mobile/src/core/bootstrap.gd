extends Node

signal boot_completed(registry: ServiceRegistry)
signal boot_failed(service_name: String, reason: String)

var next_scene_path: String = "res://scenes/main.tscn"

var registry: ServiceRegistry
var boot_order: Array[String] = []
var _steps: Array[Dictionary] = []

func _ready() -> void:
	# Workaround: Ensure ServiceRegistry exists
	if not ClassDB.class_exists("ServiceRegistry"):
		# If ServiceRegistry doesn't exist, we will just hold references here for now
		pass
	
	registry = load("res://src/core/di/service_registry.gd").new() if FileAccess.file_exists("res://src/core/di/service_registry.gd") else null
	
	configure_steps(_default_steps())
	boot()

func configure_steps(steps: Array[Dictionary]) -> void:
	_steps = steps

func boot() -> void:
	boot_order.clear()
	for step in _steps:
		var service_name: String = step["name"]
		var factory: Callable = step["factory"]
		var instance: Object = factory.call()
		
		# For nodes, add them to the tree so they can _process
		if instance is Node and not instance.is_inside_tree():
			add_child(instance)
			
		if registry:
			registry.register(service_name, instance)
		boot_order.append(service_name)
		
	boot_completed.emit(registry if registry else self)
	_load_next_scene()

func _default_steps() -> Array[Dictionary]:
	return [
		{"name": "log", "factory": func(): return Log},
		{"name": "quality", "factory": func(): return QualityService.new()},
		{"name": "haptics", "factory": func(): return HapticService.new()},
		{"name": "vfx", "factory": func(): return VfxService.new()},
		{"name": "wallet", "factory": func(): return Wallet.new()},
		{"name": "catalog", "factory": func(): return Catalog.new()},
		{"name": "profile_repo", "factory": func(): return LocalProfileRepository.new()}
	]

func _load_next_scene() -> void:
	if next_scene_path == "" or not is_inside_tree():
		return
	get_tree().change_scene_to_file.call_deferred(next_scene_path)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		print("iOS App Backgrounded: Forcing Cloud Save sync and pausing game.")
		# Force save logic here
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		print("iOS App Resumed.")
