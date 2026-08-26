class_name ServerMain
extends Node

var director: MatchDirector

func _ready() -> void:
	if not "--server" in OS.get_cmdline_args():
		queue_free()
		return
		
	print("Booting Headless Server...")
	director = MatchDirector.new()
	add_child(director)
	
	var config = Resource.new()
	config.set_meta("bot_count", 4)
	director.setup_match(config)
	
	print("Server running at 60Hz tick rate.")
