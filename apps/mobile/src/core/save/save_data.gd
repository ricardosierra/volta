class_name SaveData
extends RefCounted

## Estrutura de dados do save (docs/architecture/save-system.md §1). `to_dict()` serializa os
## blocos de PERFIL (profile.json); `settings` fica de fora — vai para settings.json via
## `settings_to_dict()`/`apply_settings_dict()`, um arquivo independente que nunca se perde por
## corrupção de perfil (ADR-0003).
##
## Preservação de campo desconhecido: cada bloco já é um Dictionary genérico (não uma lista
## fixa de propriedades tipadas), então uma chave extra dentro de um bloco (ex.:
## player["campo_novo"]) sobrevive naturalmente ao ciclo from_dict → to_dict — não precisa de
## um `_unknown` separado. Em `meta`, o mesmo raciocínio vale: `meta = data.get("meta", ...)`
## preserva o dicionário inteiro como veio (não reconstrói campo a campo), então uma chave nova
## em `meta` vinda de uma versão futura também sobrevive.

const CURRENT_SCHEMA_VERSION: int = 1
## Blocos gravados em profile.json. `settings` fica FORA — vai para settings.json
## (docs/architecture/save-system.md §2: settings nunca se perdem por corrupção de perfil).
const PROFILE_BLOCKS: Array[String] = ["player", "progress", "stats", "records", "wallet", "inventory", "achievements", "challenges"]

var meta: Dictionary = {"schema_version": CURRENT_SCHEMA_VERSION, "app_version": "0.1.0", "created_at": "", "updated_at": "", "device_id": ""}
var settings: Dictionary = {}
var player: Dictionary = {}
var progress: Dictionary = {}
var stats: Dictionary = {}
var records: Dictionary = {}
var wallet: Dictionary = {}
var inventory: Dictionary = {}
var achievements: Dictionary = {}
var challenges: Dictionary = {}


func to_dict() -> Dictionary:
	var out := {"meta": meta.duplicate(true)}
	for block in PROFILE_BLOCKS:
		out[block] = get(block).duplicate(true)
	return out


func settings_to_dict() -> Dictionary:
	return {"meta": meta.duplicate(true), "settings": settings.duplicate(true)}


func apply_settings_dict(data: Dictionary) -> void:
	settings = data.get("settings", {})


static func from_dict(data: Dictionary) -> SaveData:
	var save := SaveData.new()
	save.meta = data.get("meta", save.meta)
	for block in PROFILE_BLOCKS:
		save.set(block, data.get(block, {}))
	return save
