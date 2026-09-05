extends GutTest

## Testes de Bootstrap — ordem de boot determinística, falha não essencial não aborta o boot,
## falha essencial para o boot ali. Bootstrap no jogo é o singleton autoload; aqui criamos
## instâncias novas via preload("res://src/core/bootstrap.gd").new(), fora da árvore, e
## chamamos configure_steps()/boot() diretamente, sem depender de _ready(). Sem class_name
## em Bootstrap (ver <autoload_rules> do plano), então o tipo estático das instâncias vem de
## inferência (":=") sobre o script pré-carregado, não de um nome de classe global.

const BootstrapScript := preload("res://src/core/bootstrap.gd")


func _three_ok_steps() -> Array[Dictionary]:
	return [
		{"name": "a", "essential": true, "factory": func() -> Object: return RefCounted.new()},
		{"name": "b", "essential": true, "factory": func() -> Object: return RefCounted.new()},
		{"name": "c", "essential": true, "factory": func() -> Object: return RefCounted.new()},
	]


func test_boot_order_is_deterministic() -> void:
	var first := BootstrapScript.new()
	first.configure_steps(_three_ok_steps())
	first.boot()

	var second := BootstrapScript.new()
	second.configure_steps(_three_ok_steps())
	second.boot()

	assert_eq(first.boot_order, second.boot_order)
	assert_eq(first.boot_order, ["a", "b", "c"])


func test_non_essential_failure_does_not_abort_boot() -> void:
	var bootstrap := BootstrapScript.new()
	watch_signals(bootstrap)
	var steps: Array[Dictionary] = [
		{"name": "a", "essential": true, "factory": func() -> Object: return RefCounted.new()},
		{"name": "b", "essential": false, "factory": func() -> Object: return null},
		{"name": "c", "essential": true, "factory": func() -> Object: return RefCounted.new()},
	]
	bootstrap.configure_steps(steps)

	bootstrap.boot()

	assert_eq(bootstrap.boot_order, ["a", "c"], "passo não essencial que falhou não deveria entrar em boot_order, mas não deveria travar os seguintes")
	assert_signal_emitted(bootstrap, "boot_failed")


func test_essential_failure_stops_boot() -> void:
	var bootstrap := BootstrapScript.new()
	var steps: Array[Dictionary] = [
		{"name": "a", "essential": true, "factory": func() -> Object: return null},
		{"name": "b", "essential": true, "factory": func() -> Object: return RefCounted.new()},
	]
	bootstrap.configure_steps(steps)

	bootstrap.boot()

	assert_true(bootstrap.boot_order.is_empty(), "boot deveria parar no primeiro passo essencial que falhou")
	assert_false(bootstrap.registry.has("b"), "passo seguinte ao essencial que falhou não deveria rodar")


func test_default_steps_register_a_loaded_config_service() -> void:
	var bootstrap := BootstrapScript.new()
	bootstrap.configure_steps(bootstrap._default_steps())

	bootstrap.boot()

	assert_true(bootstrap.registry.has("config"), "Bootstrap deveria registrar um serviço 'config'")
	var config := bootstrap.registry.resolve("config")
	assert_true(config is ConfigService)
	assert_eq((config as ConfigService).runner().base_speed, 220.0, "ConfigService deveria ter carregado runner.tres, não só o fallback por coincidência")
