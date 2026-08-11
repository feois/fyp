class_name Zone
extends GameObject


@export var material: Material

@onready var mesh := $MeshInstance3D as MeshInstance3D


func update_transform() -> void:
	super.update_transform()
	
	mesh.scale.x = base_size.x
	mesh.scale.z = base_size.y


func preview_valid() -> void: mesh.set_surface_override_material(0, material)
func preview_invalid() -> void: mesh.set_surface_override_material(0, preload("res://src/objects/zones/invalid.tres"))
func clear_preview() -> void: preview_valid()


func validate() -> bool: return true


func zone_offset(index: int, size: int) -> int:
	index = (index + 1) if index % 2 == 1 else -index
	@warning_ignore("integer_division")
	return -(size / 2) + index / 2


func find_valid_area(object: GameObject) -> bool:
	for dir in Direction.values:
		var road := world.map.at(origin + Direction.vector(dir)) as Road
		
		if road && road.is_main_road():
			var dx := Direction.vector(Direction.rotate_clockwise(dir))
			var dy := Direction.vector(Direction.opposite(dir))
			var d := dx * (object.base_size.x - 1) + dy * (object.base_size.y - 1)
			
			object.rotated = Direction.to_rotation(dir)
			
			for i in range(object.base_size.x):
				var p := origin + dx * zone_offset(i, object.base_size.x)
				
				object.set_area(p, p + d, false)
				
				if validate(): return true
	
	return false
