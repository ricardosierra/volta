class_name EventBus
extends Node

## Eventos globais de baixa frequência, desacoplados. PROIBIDO emitir por frame — ver
## get_recent_emission_count() e o teste de limite em test_event_bus.gd.
signal config_loaded()
signal config_load_failed(reason: String)
signal save_loaded(result: int)
signal save_written()

const MAX_EMISSIONS_PER_SECOND: int = 5

var _emission_timestamps: Dictionary = {}


func emit_config_loaded() -> void:
	_track_emission("config_loaded")
	config_loaded.emit()


func emit_config_load_failed(reason: String) -> void:
	_track_emission("config_load_failed")
	config_load_failed.emit(reason)


func emit_save_loaded(result: int) -> void:
	_track_emission("save_loaded")
	save_loaded.emit(result)


func emit_save_written() -> void:
	_track_emission("save_written")
	save_written.emit()


func get_recent_emission_count(signal_name: String) -> int:
	return (_emission_timestamps.get(signal_name, []) as Array).size()


func _track_emission(signal_name: String) -> void:
	if not Build.is_debug():
		return
	var now := Time.get_ticks_msec() / 1000.0
	var timestamps: Array = _emission_timestamps.get(signal_name, [])
	timestamps.append(now)
	timestamps = timestamps.filter(func(t: float) -> bool: return now - t <= 1.0)
	_emission_timestamps[signal_name] = timestamps
	if timestamps.size() > MAX_EMISSIONS_PER_SECOND:
		var msg := "EventBus: '%s' emitido %d vezes no último segundo (limite %d) — EventBus é para eventos raros, não por frame" % [signal_name, timestamps.size(), MAX_EMISSIONS_PER_SECOND]
		if Log:
			Log.warn(Log.Category.ERROR, "event_bus_rate_exceeded", {"signal": signal_name, "count": timestamps.size()})
		push_warning(msg)
