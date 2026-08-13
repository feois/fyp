extends Node


@onready var world := owner as World
@onready var camera := %Camera as IsometricCamera
@onready var previews := %Previews as Previews

var origin: Vector2i
var point: Vector2i
var pressed := false
var active := false
var objects: Dictionary[GameObject, Variant] = {}


func _process(_delta: float) -> void:
	if world.ui.destruction_mode != active:
		active = world.ui.destruction_mode
		previews.clear()
		objects.clear()
		if active: previews.mode(false)
	
	if active:
		if Input.is_action_pressed(&"Select"):
			if not pressed:
				pressed = true
				%TileSelection.visible = true
				origin = camera.project_mouse_terrain().round()
				point = origin
				update()
			
			var p := Vector2i(camera.project_mouse_terrain().round())
			
			if p != point:
				point = p
				update()
		else:
			if pressed:
				pressed = false
				%TileSelection.visible = false
				for object in previews.objects(): objects[object] = null
			
			if Input.is_action_just_pressed(&"ui_accept"):
				for object in objects:
					object.destroy()
				
				previews.previews.clear()
				world.ui.cancel_all()


func update() -> void:
	var center := (origin + point) * 0.5
	var p := origin.min(point)
	var size := origin.max(point) - p + Vector2i.ONE
	
	%TileSelection.global_position = Vector3(center.x, 0, center.y)
	%TileSelection/Left.position.x = -0.45 - (size.x - 1) * 0.5
	%TileSelection/Right.position.x = +0.45 + (size.x - 1) * 0.5
	%TileSelection/Up.position.z = -0.45 - (size.y - 1) * 0.5
	%TileSelection/Down.position.z = +0.45 + (size.y - 1) * 0.5
	%TileSelection/Left.scale.z = size.y
	%TileSelection/Right.scale.z = size.y
	%TileSelection/Up.scale.x = size.x
	%TileSelection/Down.scale.x = size.x
	%TileSelection/Inner.scale = Vector3(size.x, 1, size.y)
	
	previews.clear()
	
	for x in range(size.x):
		for y in range(size.y):
			previews.add(world.map.at(p + Vector2i(x, y)))
	
	for object in objects:
		previews.add(object)
