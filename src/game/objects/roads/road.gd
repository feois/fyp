class_name Road
extends GameObject


enum Direction {
	Left,
	Right,
	Up,
	Down,
}


const straight_mesh := preload("res://src/game/objects/roads/straight.tres")
const end_mesh := preload("res://src/game/objects/roads/end.tres")
const turn_mesh := preload("res://src/game/objects/roads/turn.tres")
const tjunction_mesh := preload("res://src/game/objects/roads/tjunction.tres")
const cross_mesh := preload("res://src/game/objects/roads/cross.tres")


@onready var graph := $Graph as RoadGraph
@onready var mesh := %Model as MeshInstance3D

var directions := 0
var preview_directions := 0


static func to_vector(dir: Direction) -> Vector2i:
	match dir:
		Direction.Left: return Vector2i.LEFT
		Direction.Right: return Vector2i.RIGHT
		Direction.Up: return Vector2i.UP
		Direction.Down: return Vector2i.DOWN
	return Vector2i.ZERO


static func opposite(dir: Direction) -> Direction:
	match dir:
		Direction.Left: return Direction.Right
		Direction.Right: return Direction.Left
		Direction.Up: return Direction.Down
		Direction.Down: return Direction.Up
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	return -1


func clear_direction(preview := false) -> void:
	if preview: preview_directions = 0
	else: directions = 0
func set_direction(dir: Direction, preview := false) -> void:
	if preview: preview_directions |= 1 << dir
	else: directions |= 1 << dir
func unset_direction(dir: Direction, preview := false) -> void:
	if preview: preview_directions &= ~(1 << dir)
	else: directions &= ~(1 << dir)
func has_direction(dir: Direction, preview := false) -> bool:
	return ((directions >> dir) & 1) == 1 or (preview and ((preview_directions >> dir) & 1) == 1)
func all_directions() -> bool: return directions == (1 << Direction.size()) - 1


func update_connections() -> void:
	for neighbor in graph.neighbors(): graph.join(neighbor)


func preview_valid() -> void:
	mesh.set_surface_override_material(0, preload("res://src/game/objects/roads/road_valid.tres"))


func preview_invalid() -> void:
	mesh.set_surface_override_material(0, preload("res://src/game/objects/roads/road_invalid.tres"))


func clear_preview() -> void:
	mesh.set_surface_override_material(0, preload("res://src/game/objects/roads/road.tres"))


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
