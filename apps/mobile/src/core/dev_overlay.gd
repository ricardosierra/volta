class_name DevOverlay
extends CanvasLayer

## Overlay de debug mínimo desta fase: nome, versão, FPS, memória e tier estimado de
## dispositivo. Só existe atrás de Build.is_debug() (docs/architecture/debug-tools.md).
## A detecção completa de tier (RAM + renderer + micro-benchmark) e o menu de debug
## completo (docs/architecture/debug-tools.md) entram em fases futuras.
##
## O ColorRect de fundo em scenes/main.tscn (irmão deste nó na mesma cena) usa
## PLACEHOLDER-ART-006 -- cor provisoria (aproximacao de bg.deep), Replacement: GSD 08
## (o .tscn nao aceita comentario de linha, por isso a nota fica aqui, ao lado).

var _label: Label


func _ready() -> void:
	if not Build.is_debug():
		queue_free()
		return
	_label = Label.new()
	_label.position = Vector2(24, 48)
	add_child(_label)


func _process(_delta: float) -> void:
	if _label == null:
		return
	var fps: int = Engine.get_frames_per_second()
	var mem_mb: float = OS.get_static_memory_usage() / 1048576.0
	_label.text = "VOLTA v%s\nFPS: %d\nMem: %.1f MB\nTier: %s" % [Build.version(), fps, mem_mb, _detect_tier()]


func _detect_tier() -> String:
	# Heurística simplificada por contagem de núcleos, só para esta cena de prova de
	# pipeline. A detecção completa (RAM + renderer + micro-benchmark de 1s) entra em
	# GSD 19/20 junto dos presets de qualidade (packages/shared/config/quality/).
	var cores: int = OS.get_processor_count()
	if cores >= 8:
		return "High"
	if cores >= 5:
		return "Mid"
	return "Low"
