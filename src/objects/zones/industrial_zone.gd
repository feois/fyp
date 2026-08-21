class_name IndustrialZone
extends Zone


var industrial: Industrial


func _ready() -> void:
	super._ready()
	if not is_preview: industrial = world.industrials.pick_random() as Industrial


func process() -> void:
	if world.agent_manager.jobless.size() >= industrial.workplace.max_employee:
		if find_valid_area(industrial):
			for x in range(industrial.real_size().x):
				for y in range(industrial.real_size().y):
					var zone := world.map.at(industrial.origin + Vector2i(x, y))
					world.map.remove(zone)
					zone.queue_free()
			
			world.map.place(world.map.check(industrial.instantiate(world)))


func validate() -> bool:
	for x in range(industrial.real_size().x):
		for y in range(industrial.real_size().y):
			if world.map.at(industrial.origin + Vector2i(x, y)) is not IndustrialZone:
				return false
	return true
