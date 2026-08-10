class_name IsometricCamera
extends Camera3D


const plane := Plane(Vector3.UP, 0)
const ease_type := Tween.EASE_IN_OUT
const trans_type := Tween.TRANS_CUBIC


@export var speed := 0.0
@export var distance := 0.0
@export var rotate_animation := 0.0
@export var move_animation := 0.0
@export var min_zoom := 0.0
@export var max_zoom := 0.0
@export var zoom_speed := 0.0

@onready var world := owner as World
@onready var pivot := %CameraPivot as Node3D

var move_tween: Tween
var rotate_tween: Tween
var rotate_offset: Vector3
var target_rotation := 0.0
var terrain_point: Vector2


func _ready() -> void:
	maintain_distance()


func _process(delta: float) -> void:
	var moving := move_tween and move_tween.is_running()
	var rotating := rotate_tween and rotate_tween.is_running()
	
	if moving: return
	
	# move
	
	if not rotating:
		var input := Input.get_vector(
			&"Move Left", &"Move Right",
			&"Move Down", &"Move Up",
		)
		
		if input:
			var up := -global_basis.z
			
			up.y = 0
			
			var movement := global_basis.x * input.x + up.normalized() * input.y
			
			pivot.position += movement * (speed * size * delta)
			maintain_distance()
	
	# rotate
	
	var l := Input.is_action_just_pressed(&"Rotate Left", true)
	var r := Input.is_action_just_pressed(&"Rotate Right", true)
	
	if l != r:
		var center := get_rotated_center()
		
		if rotate_tween: rotate_tween.kill()
		
		target_rotation += -90 if l else +90
		rotate_offset = center - project(global_position, get_rotated_basis())
		
		rotate_tween = create_tween().set_parallel()
		(rotate_tween.tween_property(pivot, ^"rotation_degrees:y", target_rotation, rotate_animation)
			.set_ease(ease_type)
			.set_trans(trans_type))
		(rotate_tween.tween_property(pivot, ^"position", rotate_offset, rotate_animation)
			.as_relative()
			.set_ease(ease_type)
			.set_trans(trans_type))


func _input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP: size -= zoom_speed
			MOUSE_BUTTON_WHEEL_DOWN: size += zoom_speed
		
		size = clampf(size, min_zoom, max_zoom)


func get_rotated_center() -> Vector3:
	if rotate_tween and rotate_tween.is_running():
		var offset := rotate_offset - Tween.interpolate_value(
			Vector3.ZERO,
			rotate_offset,
			rotate_tween.get_total_elapsed_time(),
			rotate_animation,
			trans_type,
			ease_type,
		) as Vector3
		
		return project(global_position + offset, get_rotated_basis())
	return project(global_position, global_basis)


func get_rotated_basis() -> Basis:
	var radian := deg_to_rad(target_rotation - pivot.rotation_degrees.y)
	return pivot.global_basis.rotated(Vector3.UP, radian) * basis


func maintain_distance() -> void:
	var dir := -global_basis.z
	pivot.position -= (pivot.position.y - distance) / dir.y * dir # maintain distance from ground


static func project(origin: Vector3, camera_basis: Basis) -> Vector3:
	return plane.intersects_ray(origin, -camera_basis.z) as Vector3


func project_mouse(layer: int) -> CollisionObject3D:
	var origin := project_ray_origin(get_viewport().get_mouse_position())
	var end := project(origin, global_basis)
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	
	query.collision_mask = layer
	
	return space_state.intersect_ray(query).get('collider') as CollisionObject3D


func project_mouse_terrain() -> Vector2:
	var point := project(project_ray_origin(get_viewport().get_mouse_position()), global_basis)
	return Vector2(point.x, point.z)


func center_at(pos: Vector3) -> void:
	if move_tween: move_tween.kill()
	
	var point := project(global_position, global_basis)
	var center := project(project_ray_origin(world.ui.center()), global_basis)
	var offset := pos - point
	
	move_tween = create_tween()
	(move_tween.tween_property(pivot, ^"position", point - center + offset, move_animation)
		.as_relative()
		.set_ease(ease_type)
		.set_trans(trans_type))
