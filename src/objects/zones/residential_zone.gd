class_name ResidentialZone
extends Zone


var residential: Residential


func _ready() -> void:
	residential = preload("res://src/objects/residential/cottage.tscn").instantiate()


func process() -> void:
	if residential and randf() < 0.1 * world.delta:
		if find_valid_area(residential):
			for x in range(residential.real_size().x):
				for y in range(residential.real_size().y):
					var zone := world.map.at(residential.origin + Vector2i(x, y))
					world.map.remove(zone)
					zone.queue_free()
			
			world.map.place(world.map.check(residential.instantiate(world)))


func validate() -> bool:
	for x in range(residential.real_size().x):
		for y in range(residential.real_size().y):
			if world.map.at(residential.origin + Vector2i(x, y)) is not ResidentialZone:
				return false
	return true
