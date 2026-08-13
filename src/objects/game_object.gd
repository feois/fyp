class_name GameObject
extends StaticBody3D


enum Rotation {
	None,
	Clockwise,
	Counterclockwise,
	Double,
}

@export var base_size := Vector2i.ONE
@export var meshes: Array[MeshInstance3D]
@export_group("Rendering")
@export var hover_emission: float
@export var select_emission: float
@export_group("Object data")
@export var object_name: StringName
@export var object_icon: Texture2D
@export var object_price: int
@export_group("Face")
@export var face_front := false
@export var face_left := false
@export var face_right := false
@export var face_back := false

@onready var tile_highlight := %TileHighlight as MeshInstance3D

# components
@onready var power := get_node_or_null(^"Power") as Power
@onready var water := get_node_or_null(^"Water") as Water
@onready var pollution := get_node_or_null(^"Pollution") as Pollution
@onready var workplace := get_node_or_null(^"Workplace") as Workplace

var world: World
var is_preview := false
var origin := Vector2i.ZERO
var rotated := Rotation.None
var flip_x := false
var flip_y := false
var _connected := false
var _connected_stale := true
var polluted := 0.0
var noise := 0.0


func _ready() -> void: clear_preview()


func _process(_delta: float) -> void:
	if not is_preview: process()


func process() -> void: pass


@warning_ignore("shadowed_variable")
func instantiate(world: World) -> GameObject:
	var obj := duplicate() as GameObject
	obj.world = world
	obj.origin = origin
	obj.rotated = rotated
	obj.flip_x = flip_x
	obj.flip_y = flip_y
	world.road_update.connect(obj.set_stale_connection)
	return obj


func destroy() -> void:
	if is_placed(): world.map.remove(self)
	if power: power.disconnect_all()
	if water: water.disconnect_all()
	queue_free()


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


func set_area(a: Vector2i, b: Vector2i, set_size := true) -> void:
	origin = a.min(b)
	if set_size: base_size = a.max(b) - origin + Vector2i.ONE


@warning_ignore("shadowed_variable")
static func get_center(origin: Vector2i, size: Vector2i) -> Vector3:
	var p := origin * 2 + size - Vector2i.ONE
	return Vector3(p.x, 0, p.y) / 2


func update_transform() -> void:
	global_position = get_center(origin, real_size())
	
	var s := Vector3(-1 if flip_x else +1, 1, -1 if flip_y else +1)
	var r: float
	
	match rotated:
		Rotation.None: r = 0
		Rotation.Clockwise: r = -90
		Rotation.Counterclockwise: r = +90
		Rotation.Double: r = 180
	
	basis = Basis.from_euler(Vector3(0, deg_to_rad(r), 0)).scaled(s)
	
	tile_highlight.scale = Vector3(base_size.x, 1, base_size.y);


func preview_valid() -> void:
	tile_highlight.visible = true
	tile_highlight.set_surface_override_material(0, preload("res://src/objects/tile_highlight_valid.tres"))


func preview_invalid() -> void:
	tile_highlight.visible = true
	tile_highlight.set_surface_override_material(0, preload("res://src/objects/tile_highlight_invalid.tres"))


func clear_preview() -> void:
	tile_highlight.visible = false


func emit(strength: float) -> void:
	for mesh in meshes: mesh.set_instance_shader_parameter(&"selected_emission_strength", strength)


func deselect() -> void: emit(0)
func hover() -> void: emit(hover_emission)
func select() -> void: emit(select_emission)


func is_connected_to_main_road() -> bool:
	if _connected_stale:
		_connected = face_tiles().any(
			func (p: Vector2i) -> bool:
				var road := world.map.at(p) as Road
				return road and road.is_main_road()
		)
		_connected_stale = false
	return _connected


func set_stale_connection() -> void: _connected_stale = true


func offset(x: int, y: int) -> Vector2i:
	if flip_x: x = base_size.x - 1 - x
	if flip_y: y = base_size.y - 1 - y
	match rotated:
		Rotation.None: return Vector2i(x, y)
		Rotation.Clockwise: return Vector2i(base_size.y - 1 - y, x)
		Rotation.Double: return Vector2i(base_size.x - 1 - x, base_size.y - 1 - y)
		Rotation.Counterclockwise: return Vector2i(y, base_size.x - 1 - x)
	return Vector2i.ZERO


func face_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	
	if face_front:
		for i in range(base_size.x): tiles.append(origin + offset(i, base_size.y))
	if face_left:
		for i in range(base_size.y): tiles.append(origin + offset(-1, i))
	if face_right:
		for i in range(base_size.y): tiles.append(origin + offset(base_size.x, i))
	if face_back:
		for i in range(base_size.x): tiles.append(origin + offset(i, -1))
	
	return tiles
