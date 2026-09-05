@tool
extends EditorScript

# Simple tool to generate or validate arena masks
func _run() -> void:
	print("Running Arena Validation Tool...")
	var arenas := ["archipelago", "rift", "crossroads", "halo"]
	for a in arenas:
		var res_path := "res://resources/arenas/" + a + ".tres"
		if FileAccess.file_exists(res_path):
			var arena: ArenaDefinition = load(res_path)
			if arena.is_valid():
				print(a, ": VALID")
			else:
				print(a, ": INVALID")
