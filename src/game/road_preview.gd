class_name RoadPreview
extends Node


enum RoadType {
	None,
	Start,
	Middle,
	End,
}


const road_scene := preload("res://src/objects/roads/road.tscn")


@onready var world := owner as World
@onready var previews := %Previews as Previews

var start: Road
var pool: Array[Road] = []
var roads: Array[Road] = []
var obstacle: GameObject
var obstacle_index := 0
var valid := false
var direction: Road.Direction


func is_previewing() -> bool: return start != null


func direction_to(pos: Vector2i) -> Road.Direction:
	var d := pos - start.origin
	
	if absi(d.x) < absi(d.y): d.x = 0
	else: d.y = 0
	
	match d.sign():
		Vector2i.LEFT: return Road.Direction.Left
		Vector2i.RIGHT: return Road.Direction.Right
		Vector2i.UP: return Road.Direction.Up
		Vector2i.DOWN: return Road.Direction.Down
	
	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	return -1


func new_preview() -> Road:
	if pool.is_empty():
		for i in range(8):
			var r := road_scene.instantiate() as Road
			
			r.world = world
			r.is_preview = true
			
			pool.append(r)
	
	var road := pool.pop_back() as Road
	
	add_child(road)
	previews.add(road)
	
	return road


func destroy_preview(preview: Road) -> void:
	pool.push_back(preview)
	remove_child(preview)


func get_end() -> Road: return null if roads.is_empty() else roads[-1]


func start_at(pos: Vector2i) -> bool:
	if is_previewing(): return false
	
	var obj := world.map.at(pos)
	
	if obj:
		if obj is Road and not obj.all_directions(): start = obj as Road
		else: return false
	else:
		start = new_preview()
		start.origin = pos
		start.update_transform()
	
	previews.clear()
	previews.add(start)
	
	world.ui.push(RoadPreview, cancel)
	
	valid = false
	
	return true


func point(pos: Vector2i) -> void:
	if not is_previewing(): return
	
	if start.origin == pos:
		if not start.is_preview: set_directions(start, RoadType.None)
		clear_all()
		valid = false
		previews.mode(false)
		return
	
	var d := direction_to(pos)
	var dv := Road.to_vector(d)
	var offset := pos - start.origin
	@warning_ignore("integer_division")
	var n := (offset.x / dv.x) if dv.y == 0 else (offset.y / dv.y)
	
	if d != direction or roads.is_empty():
		direction = d
		set_directions(start, RoadType.Start)
		clear_all()
	
	if obstacle:
		if n > obstacle_index: return
		clear_obstacle()
	
	if n == roads.size(): return
	
	if n < roads.size():
		while n < roads.size(): clear(roads.pop_back())
		set_directions(get_end(), RoadType.End)
	else:
		set_directions(get_end(), RoadType.Middle)
		
		for i in range(roads.size(), n):
			var p := start.origin + dv * (i + 1)
			var preview: Road
			var obj := world.map.at(p)
			
			if obj:
				if obj is Road: preview = obj as Road
				else:
					obstacle = obj
					obstacle_index = i
					previews.add(obstacle)
					previews.mode(false)
					return
			else:
				preview = new_preview()
				preview.origin = p
				preview.update_transform()
			
			previews.add(preview);
			set_directions(preview, RoadType.Middle)
			roads.append(preview)
		
		set_directions(get_end(), RoadType.End)
	
	valid = validate()
	previews.mode(valid)


func set_directions(preview: Road, mode: RoadType) -> void:
	if not preview: return
	
	preview.clear_direction(true)
	
	match mode:
		RoadType.None: pass
		RoadType.Start: preview.set_direction(direction, true)
		RoadType.Middle:
			preview.set_direction(direction, true)
			preview.set_direction(Road.opposite(direction), true)
		RoadType.End: preview.set_direction(Road.opposite(direction), true)
	
	preview.update_mesh()


func validate() -> bool:
	if start.has_direction(direction): return false
	if roads.any(func (road: Road) -> bool: return road.has_direction(Road.opposite(direction))):
		return false
	return true


func cancel() -> void:
	if not is_previewing(): return
	
	world.ui.pop(RoadPreview)
	
	clear_all()
	clear(start)
	start = null


func clear_obstacle() -> void:
	valid = validate()
	set_directions(get_end(), RoadType.End)
	previews.remove(obstacle)
	previews.mode(valid)
	obstacle = null


func clear(preview: Road) -> void:
	previews.remove(preview)
	if preview.is_preview: destroy_preview(preview)
	else: preview.update_mesh()


func clear_all() -> void:
	clear_obstacle()
	for preview in roads: clear(preview)
	roads.clear()
