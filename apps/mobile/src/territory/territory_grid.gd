class_name TerritoryGrid
extends RefCounted

var width: int
var height: int
var cell_count: int

var _owner: PackedByteArray
var _arc: PackedByteArray
var _claim_count: PackedInt32Array

func setup(w: int, h: int, blocked: Array[Vector2i] = []) -> void:
	width = w
	height = h
	cell_count = w * h
	
	_owner = PackedByteArray()
	_owner.resize(cell_count)
	_owner.fill(255) # 255 = neutral/blocked initially, we'll refine this
	
	_arc = PackedByteArray()
	_arc.resize(cell_count)
	_arc.fill(255)
	
	# Assuming max 8 players
	_claim_count = PackedInt32Array()
	_claim_count.resize(8)
	_claim_count.fill(0)
	
	reset()
	
	for b in blocked:
		if is_valid(b.x, b.y):
			var idx = cell_index(b.x, b.y)
			_owner[idx] = 255
			_arc[idx] = 255

func reset() -> void:
	_owner.fill(254) # 254 = neutral
	_arc.fill(255) # 255 = no arc
	_claim_count.fill(0)

func is_valid(x: int, y: int) -> bool:
	return x >= 0 and x < width and y >= 0 and y < height

func cell_index(x: int, y: int) -> int:
	return y * width + x

func owner_of(x: int, y: int) -> int:
	if is_valid(x, y):
		return _owner[cell_index(x, y)]
	return 255

func arc_owner_of(x: int, y: int) -> int:
	if is_valid(x, y):
		return _arc[cell_index(x, y)]
	return 255

func is_blocked(x: int, y: int) -> bool:
	return owner_of(x, y) == 255

func set_owner(x: int, y: int, runner_id: int) -> void:
	if not is_valid(x, y): return
	var idx = cell_index(x, y)
	var old = _owner[idx]
	if old == runner_id or old == 255: return
	
	if old != 254 and old >= 0 and old < 8:
		_claim_count[old] -= 1
		
	_owner[idx] = runner_id
	if runner_id >= 0 and runner_id < 8:
		_claim_count[runner_id] += 1

func seed_claim(runner_id: int, center_x: int, center_y: int, size: int) -> void:
	var half = size / 2
	for y in range(center_y - half, center_y - half + size):
		for x in range(center_x - half, center_x - half + size):
			if is_valid(x, y) and not is_blocked(x, y):
				set_owner(x, y, runner_id)

func release_claim(runner_id: int) -> void:
	for i in range(cell_count):
		if _owner[i] == runner_id:
			_owner[i] = 254
	_claim_count[runner_id] = 0

func claim_percent(runner_id: int) -> float:
	var playable = 0
	for i in range(cell_count):
		if _owner[i] != 255:
			playable += 1
	if playable == 0: return 0.0
	return float(_claim_count[runner_id]) / float(playable)
