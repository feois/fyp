extends Node


@onready var world := owner as World
@onready var camera := %Camera as IsometricCamera


var hovered: GameObject
var selected: GameObject


func _process(_delta: float) -> void:
	if not world.previews.empty():
		hover(null)
		select(null)
		return
	
	if get_viewport().gui_get_hovered_control():
		hover(null)
		return
	
	hover(camera.project_mouse(1 << 2) as GameObject)
	
	if Input.is_action_just_pressed(&"Select"):
		select(hovered)


func hover(object: GameObject) -> void:
	if object == hovered: return
	if hovered: hovered.deselect()
	hovered = null
	if object == selected: return
	hovered = object
	if hovered: hovered.hover()


func select(object: GameObject = null) -> void:
	if object == selected: return
	if object == hovered: hover(null)
	if selected: selected.deselect()
	selected = object
	world.ui.pop(self)
	if object:
		selected.select()
		world.ui.push(self, select)
