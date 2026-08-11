extends Control


@export var ui: UI

@onready var camera := ui.world.camera

var hovered: GameObject
var selected: GameObject
var stack: Array[Callable] = [select]


func _ready() -> void: visible = false


func _process(_delta: float) -> void:
	if get_viewport().gui_get_hovered_control() or not ui.world.previews.empty(): hover(null)
	else:
		hover(camera.project_mouse(1 << 2) as GameObject)
		
		if Input.is_action_just_pressed(&"Select", true): stack.back().call(hovered)
	
	if %Info.visible: info()


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
	ui.cancel_all()
	selected = object
	if object:
		selected.select()
		camera.center_at(selected.global_position)
		visible = true
		%Tabs/Info.button.button_pressed = true
		%Tabs/Power.visible = object.power != null
		ui.push(self, select)
	else:
		visible = false


func info() -> void:
	pass
