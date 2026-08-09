class_name GameObject
extends StaticBody3D


enum Rotation {
	None,
	Clockwise,
	Counterclockwise,
	Double,
}

@export var meshes: Array[MeshInstance3D]
@export var base_size := Vector2i.ONE
@export var object_name: StringName
@export var object_icon: Texture2D
@export var object_price: int
@export var hover_emission: float
@export var select_emission: float

@onready var tile_highlight := %TileHighlight as MeshInstance3D
@onready var power := get_node_or_null(^"Power") as Power

var world: World
var is_preview := false
var origin := Vector2i.ZERO
var rotated := Rotation.None
var flip_x := false
var flip_y := false
var _connected := false
var _connected_stale := true


func _ready() -> void:
	clear_preview()


func _process(_delta: float) -> void:
	if not is_preview: process()


func process() -> void: pass


@warning_ignore("shadowed_variable")
func instantiate(world: World) -> GameObject:
	var obj := duplicate()
	obj.world = world
	obj.origin = origin
	obj.rotated = rotated
	obj.flip_x = flip_x
	obj.flip_y = flip_y
	world.road_update.connect(func () -> void: _connected_stale = true)
	return obj


func is_placed() -> bool: return world.map.at(origin) == self


func real_size(r = null) -> Vector2i:
	r = r if r else rotated
	return base_size if r == Rotation.None or r == Rotation.Double else Vector2i(base_size.y, base_size.x)


func rotate_clockwise() -> void:
	match rotated:
		Rotation.None: rotated = Rotation.Clockwise
		Rotation.Clockwise: rotated = Rotation.Double
		Rotation.Counterclockwise: rotated = Rotation.None
		Rotation.Double: rotated = Rotation.Counterclockwise


func rotate_counterclockwise() -> void:
	match rotated:
		Rotation.None: rotated = Rotation.Counterclockwise
		Rotation.Clockwise: rotated = Rotation.None
		Rotation.Counterclockwise: rotated = Rotation.Double
		Rotation.Double: rotated = Rotation.Clockwise


func set_area(a: Vector2i, b: Vector2i) -> void:
	origin = a.min(b)
	base_size = a.max(b) - origin + Vector2i.ONE


@warning_ignore("shadowed_variable")
static func get_center(origin: Vector2i, size: Vector2i) -> Vector3:
	var p := origin * 2 + size - Vector2i.ONE
	return Vector3(p.x, 0, p.y) / 2


func update_transform() -> void:
	global_position = get_center(origin, real_size())
	
	match rotated:
		Rotation.None: rotation_degrees.y = 0
		Rotation.Clockwise: rotation_degrees.y = 90
		Rotation.Counterclockwise: rotation_degrees.y = -90
		Rotation.Double: rotation_degrees.y = 180
	
	scale.x = -1 if flip_x else +1
	scale.y = -1 if flip_y else +1
	
	tile_highlight.scale = Vector3(base_size.x, 1, base_size.y);


func preview_valid() -> void:
	tile_highlight.visible = true
	tile_highlight.set_surface_override_material(0, preload("res://src/game/objects/tile_highlight_valid.tres"))


func preview_invalid() -> void:
	tile_highlight.visible = true
	tile_highlight.set_surface_override_material(0, preload("res://src/game/objects/tile_highlight_invalid.tres"))


func clear_preview() -> void:
	tile_highlight.visible = false


func emit(strength: float) -> void:
	for mesh in meshes: mesh.set_instance_shader_parameter(&"selected_emission_strength", strength)


func deselect() -> void: emit(0)
func hover() -> void: emit(hover_emission)
func select() -> void: emit(select_emission)


func is_connected_to_main_road() -> bool:
	if _connected_stale:
		# todo
		_connected_stale = false
	return _connected
