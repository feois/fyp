class_name Road
extends GameObject


const straight_mesh := preload("res://src/objects/roads/straight.tres")
const end_mesh := preload("res://src/objects/roads/end.tres")
const turn_mesh := preload("res://src/objects/roads/turn.tres")
const tjunction_mesh := preload("res://src/objects/roads/tjunction.tres")
const cross_mesh := preload("res://src/objects/roads/cross.tres")


@onready var graph := $Graph as RoadGraph
@onready var mesh := %Model as MeshInstance3D

var directions := 0
var preview_directions := 0


func clear_direction(preview := false) -> void:
	if preview: preview_directions = 0
	else: directions = 0
func set_direction(dir: Direction.Enum, preview := false) -> void:
	if preview: preview_directions |= 1 << dir
	else: directions |= 1 << dir
func unset_direction(dir: Direction.Enum, preview := false) -> void:
	if preview: preview_directions &= ~(1 << dir)
	else: directions &= ~(1 << dir)
func has_direction(dir: Direction.Enum, preview := false) -> bool:
	return ((directions >> dir) & 1) == 1 or (preview and ((preview_directions >> dir) & 1) == 1)
func all_directions() -> bool: return directions == (1 << Direction.count) - 1


func update_connections() -> void:
	for neighbor in graph.neighbors(): graph.join(neighbor)


func preview_valid() -> void:
	mesh.set_surface_override_material(0, preload("res://src/objects/roads/road_valid.tres"))


func preview_invalid() -> void:
	mesh.set_surface_override_material(0, preload("res://src/objects/roads/road_invalid.tres"))


func clear_preview() -> void:
	mesh.set_surface_override_material(0, preload("res://src/objects/roads/road.tres"))


func update_mesh() -> void:
	var p := world.previews.has(self)
	var l := has_direction(Direction.Left, p)
	var r := has_direction(Direction.Right, p)
	var u := has_direction(Direction.Up, p)
	var d := has_direction(Direction.Down, p)
	
	match [l, r, u, d].count(true):
		1:
			mesh.mesh = end_mesh
			match 0:
				0 when l: rotated = Rotation.Clockwise
				0 when r: rotated = Rotation.Counterclockwise
				0 when u: rotated = Rotation.None
				0 when d: rotated = Rotation.Double
		2 when l && r: mesh.mesh = straight_mesh; rotated = Rotation.Clockwise
		2 when u && d: mesh.mesh = straight_mesh; rotated = Rotation.None
		2:
			mesh.mesh = turn_mesh
			match 0:
				0 when l && u: rotated = Rotation.Double
				0 when u && r: rotated = Rotation.Clockwise
				0 when r && d: rotated = Rotation.None
				0 when d && l: rotated = Rotation.Counterclockwise
		3:
			mesh.mesh = tjunction_mesh
			match 0:
				0 when !r: rotated = Rotation.Double
				0 when !d: rotated = Rotation.Clockwise
				0 when !l: rotated = Rotation.None
				0 when !u: rotated = Rotation.Counterclockwise
		4: mesh.mesh = cross_mesh; rotated = Rotation.None
		_: mesh.mesh = null; rotated = Rotation.None
	
	update_transform()


func is_main_road() -> bool:
	var root := graph.root() as RoadGraph
	return root and root.is_main_road


func _get_road(direction: Direction.Enum) -> Road:
	return world.map.at(origin - Direction.vector(direction)) as Road if has_direction(direction) else null


func destroy() -> void:
	super.destroy()
	
	var l := _get_road(Direction.Left)
	var r := _get_road(Direction.Right)
	var u := _get_road(Direction.Up)
	var d := _get_road(Direction.Down)
	
	if l: l.graph.mark_dirty(); l.unset_direction(Direction.Right)
	if r: r.graph.mark_dirty(); r.unset_direction(Direction.Left)
	if u: u.graph.mark_dirty(); u.unset_direction(Direction.Down)
	if d: d.graph.mark_dirty(); d.unset_direction(Direction.Up)
	
	if l: l.graph.rebuild()
	if r: r.graph.rebuild()
	if u: u.graph.rebuild()
	if d: d.graph.rebuild()
