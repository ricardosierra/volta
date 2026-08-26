class_name Loadout
extends RefCounted

var slots: Dictionary = {
	CosmeticItem.Type.SKIN: "skin_default",
	CosmeticItem.Type.ARC: "arc_default",
	CosmeticItem.Type.SEAL_FX: "seal_default",
	CosmeticItem.Type.TITLE: "title_default",
	CosmeticItem.Type.FRAME: "frame_default",
	CosmeticItem.Type.THEME: "theme_default"
}

func equip(type: int, id: String) -> void:
	slots[type] = id

func get_equipped(type: int) -> String:
	return slots.get(type)
