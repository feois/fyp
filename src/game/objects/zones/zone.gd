class_name Zone
extends GameObject


@export var material: Material

@onready var mesh := $MeshInstance3D as MeshInstance3D


func update_transform() -> void:
	super.update_transform()
	
	mesh.scale.x = base_size.x
	mesh.scale.z = base_size.y


func preview_valid() -> void: mesh.set_surface_override_material(0, material)
func preview_invalid() -> void: mesh.set_surface_override_material(0, preload("res://src/game/objects/zones/invalid.tres"))
func clear_preview() -> void: preview_valid()
