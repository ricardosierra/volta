extends GutTest

## Testes de EventBus — assinatura/desassinatura de sinal tipado, valor do argumento
## carregado por save_loaded, e a trava de debug contra emissão acima do limite por
## segundo (EventBus é para eventos raros, não por frame).


func test_subscribe_receives_emission() -> void:
	# GDScript captura variáveis locais por valor em closures — usar um Array de 1
	# elemento como "caixa" mutável para a lambda poder sinalizar de volta ao teste.
	var bus := EventBus.new()
	var received := [false]
	var callback := func() -> void: received[0] = true
	bus.config_loaded.connect(callback)

	bus.emit_config_loaded()

	assert_true(received[0])


func test_unsubscribe_stops_delivery() -> void:
	var bus := EventBus.new()
	var received := [false]
	var callback := func() -> void: received[0] = true
	bus.config_loaded.connect(callback)
	bus.config_loaded.disconnect(callback)

	bus.emit_config_loaded()

	assert_false(received[0])


func test_save_loaded_carries_result_value() -> void:
	var bus := EventBus.new()
	var received_result := [-1]
	var callback := func(result: int) -> void: received_result[0] = result
	bus.save_loaded.connect(callback)

	bus.emit_save_loaded(SaveService.SaveResult.RESTORED_FROM_BACKUP)

	assert_eq(received_result[0], SaveService.SaveResult.RESTORED_FROM_BACKUP)


func test_rate_limit_flagged_after_threshold() -> void:
	if not Build.is_debug():
		gut.p("skipped: not a debug build")
		pending("skipped: not a debug build")
		return

	var bus := EventBus.new()

	for i in range(EventBus.MAX_EMISSIONS_PER_SECOND + 1):
		bus.emit_config_loaded()

	assert_true(bus.get_recent_emission_count("config_loaded") > EventBus.MAX_EMISSIONS_PER_SECOND)
