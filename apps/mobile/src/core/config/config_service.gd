class_name ConfigService
extends RefCounted

## Carrega, valida e expõe os 6 balances tipados (docs/architecture/configuration.md §2).
## Config inválida (faixa ou coerência) falha alto em debug (push_error + Log.error) e cai no
## embutido em release — nunca aceita valor fora de faixa silenciosamente.

const BASE_PATH: String = "res://resources/config/balance/"

var _runner: RunnerBalance
var _territory: TerritoryBalance
var _backwash: BackwashBalance
var _score: ScoreBalance
var _surge: SurgeBalance
var _camera: CameraBalance
var _load_error: String = ""


func load_all() -> bool:
	_runner = _load_and_validate("runner.tres", RunnerBalance.new()) as RunnerBalance
	_territory = _load_and_validate("territory.tres", TerritoryBalance.new()) as TerritoryBalance
	_backwash = _load_and_validate("backwash.tres", BackwashBalance.new()) as BackwashBalance
	_score = _load_and_validate("score.tres", ScoreBalance.new()) as ScoreBalance
	_surge = _load_and_validate("surge.tres", SurgeBalance.new()) as SurgeBalance
	_camera = _load_and_validate("camera.tres", CameraBalance.new()) as CameraBalance
	_check_coherence()
	return _load_error == ""


func runner() -> RunnerBalance:
	return _runner


func territory() -> TerritoryBalance:
	return _territory


func backwash() -> BackwashBalance:
	return _backwash


func score() -> ScoreBalance:
	return _score


func surge() -> SurgeBalance:
	return _surge


func camera() -> CameraBalance:
	return _camera


func get_load_error() -> String:
	return _load_error


func _check_coherence() -> void:
	var incoherent := ConfigValidator.validate_coherence(_runner, _territory, _camera)
	if incoherent.is_empty():
		return
	var msg := "config incoerente entre arquivos: %s" % [incoherent]
	_load_error += msg + "; "
	if Log:
		Log.error(Log.Category.ERROR, "config_incoherent", {"fields": incoherent})
	if Build.is_debug():
		push_error(msg)  # falha alto em debug
	_reset_to_embedded()  # cai no embutido — os defaults são coerentes por construção


func _reset_to_embedded() -> void:
	_runner = RunnerBalance.new()
	_territory = TerritoryBalance.new()
	_backwash = BackwashBalance.new()
	_score = ScoreBalance.new()
	_surge = SurgeBalance.new()
	_camera = CameraBalance.new()


func _load_and_validate(file_name: String, fallback: Resource) -> Resource:
	var loaded: Resource = ResourceLoader.load(BASE_PATH + file_name)
	var candidate: Resource = loaded if loaded != null else fallback
	var invalid := ConfigValidator.validate(candidate)
	if not invalid.is_empty():
		var msg := "config inválida em %s: campos fora de faixa: %s" % [file_name, invalid]
		_load_error += msg + "; "
		if Log:
			Log.error(Log.Category.ERROR, "config_invalid", {"file": file_name, "fields": invalid})
		if Build.is_debug():
			push_error(msg)  # falha alto em debug
			return fallback
		return fallback  # cai no embutido em release
	return candidate
