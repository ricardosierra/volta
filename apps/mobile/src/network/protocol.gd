class_name NetworkProtocol
extends RefCounted

enum MsgType {
	JOIN,
	LEAVE,
	INPUT,
	SNAPSHOT,
	PING
}

static func pack_input(tick: int, direction: Vector2) -> PackedByteArray:
	var buf := StreamPeerBuffer.new()
	buf.put_u8(MsgType.INPUT)
	buf.put_u32(tick)
	buf.put_float(direction.x)
	buf.put_float(direction.y)
	return buf.data_array
	
static func unpack_input(data: PackedByteArray) -> Dictionary:
	var buf := StreamPeerBuffer.new()
	buf.data_array = data
	var type := buf.get_u8()
	var tick := buf.get_u32()
	var x := buf.get_float()
	var y := buf.get_float()
	return {"type": type, "tick": tick, "dir": Vector2(x, y)}
