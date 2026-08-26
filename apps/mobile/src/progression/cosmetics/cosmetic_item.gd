class_name CosmeticItem
extends Resource

enum Type { SKIN, ARC, SEAL_FX, TITLE, FRAME, THEME }
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

@export var id: String
@export var type: Type
@export var rarity: Rarity
@export var name: String
@export var description: String
@export var price_sparks: int = 0
@export var price_prisms: int = 0

# Visuals
@export var texture_path: String
@export var shader_path: String
@export var vfx_path: String
