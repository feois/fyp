class_name CommercialZone
extends Zone


var commercial: Commercial


func _ready() -> void:
	super._ready()
	if not is_preview: commercial = world.commercials.pick_random() as Commercial


func process() -> void:
	if world.production - world.total_sales > commercial.uneducated_sales * commercial.workplace.max_employee:
		if find_valid_area(commercial):
			for x in range(commercial.real_size().x):
				for y in range(commercial.real_size().y):
					var zone := world.map.at(commercial.origin + Vector2i(x, y))
					world.map.remove(zone)
					zone.queue_free()
			
			world.map.place(world.map.check(commercial.instantiate(world)))


func validate() -> bool:
	for x in range(commercial.real_size().x):
		for y in range(commercial.real_size().y):
			if world.map.at(commercial.origin + Vector2i(x, y)) is not CommercialZone:
				return false
	return true
