class_name Map
extends Node


@onready var objects := %Objects as Node3D


class Check extends RefCounted:
	var map: Map
	var _valid: bool
	var timestamp: int
	var origin: Vector2i
	var size: Vector2i
	var obj: GameObject
	var obstacles: Array[GameObject] = []
	
	func check() -> void:
		var objects := {}
		
		for x in range(size.x):
			for y in range(size.y):
				var o := map.at(obj.origin + Vector2i(x, y))
				if o:
					objects[o] = null
					_valid = false
					return
		
		obstacles.assign(objects.keys())
		_valid = true
	
	
	func is_valid() -> bool:
		update()
		return _valid
	
	func update() -> bool:
		if obj.origin != origin or obj.real_size() != size or timestamp != map.timestamp:
			origin = obj.origin
			size = obj.real_size()
			timestamp = map.timestamp
			check()
			return true
		
		return false
	
	func get_obstacles() -> Array[GameObject]:
		obstacles.clear()
		
		for x in range(obj.real_size().x):
			for y in range(obj.real_size().y):
				var o := map.map.get(obj.origin + Vector2i(x, y)) as GameObject
				if o: obstacles.append(o)
		
		return obstacles


@onready var world = owner as World

var map: Dictionary[Vector2i, GameObject] = {}
var timestamp := 0


func at(pos: Vector2i) -> GameObject: return map[pos] if pos in map else null


func check(obj: GameObject, pos = null, rotate = null) -> Map.Check:
	var c := Check.new()
	
	c.obj = obj
	c.map = self
	c.timestamp = timestamp
	if pos != null: c.origin = pos
	if rotate != null: c.rotated = rotate
	c.check()
	
	return c


@warning_ignore("shadowed_variable")
func place(check: Check) -> GameObject:
	if not check.is_valid(): return null
	
	var obj := check.obj
	
	for x in range(obj.real_size().x):
		for y in range(obj.real_size().y):
			map[obj.origin + Vector2i(x, y)] = obj
	
	objects.add_child(obj)
	obj.update_transform()
	
	if obj is Road: world.road_update.emit()
	
	timestamp += 1
	
	return obj


func remove(object: GameObject) -> void:
	if map[object.origin] == object:
		for x in range(object.real_size().x):
			for y in range(object.real_size().y):
				map.erase(object.origin + Vector2i(x, y))
		
		timestamp += 1
