class_name LogSink
extends RefCounted

## Interface abstrata de destino de log (arquivo, overlay, telemetria...).
## Subclasses implementam write(). A base falha alto se usada diretamente, para deixar
## claro que um sink concreto precisa sobrescrever o método.

func write(category: int, level: int, key: String, data: Dictionary) -> void:
	push_error("LogSink.write() não implementado em %s" % [get_script()])
