class_name UnlockService
extends Node

var catalog: Catalog
var inventory: Inventory
var wallet: Wallet

signal item_unlocked(item_id: String)
signal unlock_failed(reason: String)

func attempt_purchase(item_id: String) -> bool:
	if inventory.has_item(item_id):
		unlock_failed.emit("ALREADY_OWNED")
		return false
		
	var item = catalog.get_item(item_id)
	if not item: return false
	
	if item.price_sparks > 0:
		if wallet.spend_sparks(item.price_sparks, "unlock_" + item_id):
			_grant(item_id)
			return true
		else:
			unlock_failed.emit("INSUFFICIENT_SPARKS")
			return false
			
	if item.price_prisms > 0:
		# Prisms logic similar
		pass
		
	return false

func _grant(item_id: String) -> void:
	inventory.add_item(item_id)
	item_unlocked.emit(item_id)
