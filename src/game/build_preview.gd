extends Node3D


@onready var world := owner as World
@onready var cam := %Camera as IsometricCamera
@onready var previews := %Previews as Previews
@onready var road_preview := %RoadPreview as RoadPreview


var point: Vector2i

var object: GameObject
var check: Map.Check

var zoning := false
var zone_origin: Vector2i


func _ready() -> void:
	world.ui.object_selected.connect(set_object)


func _process(_delta: float) -> void:
	if not object:
		visible = false
		return
	
	var size := object.real_size() if object else Vector2i.ONE
	var offset := (size + Vector2i.ONE) % 2
	var pos := (cam.project_mouse_terrain() - offset * 0.5).round()
	
	@warning_ignore("integer_division")
	point = Vector2i(pos) + offset - size / 2
	
	$Grid.set_size(size)
	$Grid.position = GameObject.get_center(point, size)
	visible = true
	
	if object is Road: preview_road(object as Road)
	elif object is Zone: preview_zone(object as Zone)
	else: preview_build()


func notify_blocked() -> void: world.ui.notify("Cannot build on this area!")


func build_input() -> bool:
	return Input.is_action_just_pressed(&"Place") and not get_viewport().gui_get_hovered_control()


func preview_build() -> void:
	object.origin = point
	
	var l := Input.is_action_just_pressed(&"Place Rotate Left", true)
	var r := Input.is_action_just_pressed(&"Place Rotate Right", true)
	
	if l != r:
		if l: object.rotate_counterclockwise()
		else: object.rotate_clockwise()
	
	if Input.is_action_just_pressed(&"Flip X", true): object.flip_x = not object.flip_x
	if Input.is_action_just_pressed(&"Flip Y", true): object.flip_y = not object.flip_y
	
	object.update_transform()
	
	if check_update():
		object.polluted = 0
		object.noise = 0
		world.reapply_effects.emit(object)
		world.ui.pollution_warning.visible = Pollution.is_dangerous(object.polluted)
		world.ui.noise_warning.visible = false
	
	if build_input():
		if check.is_valid():
			check.obj = object.instantiate(world)
			world.map.place(check)
			check = null
		else: notify_blocked()


func preview_road(road: Road) -> void:
	if road_preview.is_previewing():
		road.visible = false
		road_preview.point(point)
		
		if build_input():
			if road_preview.valid:
				var last := Vector2i.ZERO
				
				for i in range(-1, road_preview.roads.size()):
					var r := road_preview.start if i == -1 else road_preview.roads[i]
					var d := r.preview_directions
					
					if r.is_preview:
						r = r.instantiate(world) as Road
						world.map.place(world.map.check(r))
					
					r.directions |= d
					r.update_mesh()
					r.update_connections()
					last = r.origin
				
				world.road_update.emit()
				road_preview.cancel()
				previews.clear()
				previews.add(road)
				
				if Input.is_action_just_pressed(&"Chain Place"):
					if not road_preview.start_at(last): notify_blocked()
			else: notify_blocked()
	else:
		if point != road.origin:
			road.origin = point
			road.update_transform()
			previews.clear();
			
			var obstacle := world.map.at(point)
			
			if obstacle:
				road.visible = false
				previews.mode(obstacle is Road and not obstacle.all_directions())
				previews.add(obstacle)
			else:
				road.visible = true
				previews.mode(true)
				previews.add(road)
		
		if build_input():
			if previews.valid: road_preview.start_at(point)
			else: notify_blocked()


func preview_zone(zone: Zone) -> void:
	if zoning:
		zone.set_area(zone_origin, point)
		zone.update_transform()
		
		check_update()
		
		if build_input():
			if check.is_valid():
				var n := zone.base_size
				
				zone.base_size = Vector2i.ONE
				
				for x in range(n.x):
					for y in range(n.y):
						check.obj = zone.instantiate(world)
						check.obj.origin = zone.origin + Vector2i(x, y)
						world.map.place(check)
				
				world.ui.pop(Zone)
				zoning = false
				check = null
			else: notify_blocked()
		
		zone.base_size = Vector2i.ONE
	else:
		zone.origin = point
		zone.base_size = Vector2i.ONE
		zone.update_transform()
		
		check_update()
		
		if build_input():
			if previews.valid:
				zoning = true
				zone_origin = point
				
				world.ui.push(Zone, func () -> void: zoning = false)
			else: notify_blocked()


func check_update() -> bool:
	if check == null: check = world.map.check(object, point)
	elif not check.update(): return false
	
	previews.clear(object)
	previews.mode(check.is_valid())
	
	if not check.is_valid():
		for obstacle in check.get_obstacles(): previews.add(obstacle)
	
	return true


func set_object(obj: GameObject) -> void:
	@warning_ignore("incompatible_ternary")
	if (obj.scene_file_path if obj else null) == (object.scene_file_path if object else null): return
	
	if object:
		previews.clear()
		object.queue_free()
		object = null
		check = null
		world.ui.building = false
	
	if obj:
		object = obj.instantiate(world)
		object.is_preview = true
		add_child(object)
		previews.add(object)
		world.ui.building = true
