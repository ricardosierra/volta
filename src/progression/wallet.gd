class_name Wallet
extends Node

var sparks: int = 0
var prisms: int = 0

signal balance_changed(type: String, amount: int)

func add_sparks(amount: int, source: String = "match") -> void:
	if amount <= 0: return
	sparks += amount
	balance_changed.emit("sparks", sparks)

func spend_sparks(amount: int, reason: String = "store") -> bool:
	if sparks >= amount:
		sparks -= amount
		balance_changed.emit("sparks", sparks)
		return true
	return false

func add_prisms(amount: int, source: String = "iap") -> void:
	if amount <= 0: return
	prisms += amount
	balance_changed.emit("prisms", prisms)
