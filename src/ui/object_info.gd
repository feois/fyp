extends Control


@export var ui: UI

@onready var camera := ui.world.camera

var hovered: GameObject
var selected: GameObject
var stack: Array[Callable] = [select]


func _ready() -> void:
	visible = false
	for content in %Content.get_children(): content.visible = false


func _process(_delta: float) -> void:
	if get_viewport().gui_get_hovered_control() or not ui.world.previews.empty(): hover(null)
	else:
		hover(camera.project_mouse(1 << 2) as GameObject)
		
		if Input.is_action_just_pressed(&"Select", true): stack.back().call(hovered)
	
	if %Info.visible: info()
	if %Power.visible: power()


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
		if %Power.visible: %Power.visible = false
		visible = false


func info() -> void:
	%Name.text = selected.object_name
	%Icon.texture = selected.object_icon


func power() -> void:
	var p := selected.power
	%PowerGeneration.visible = p.generation > 0
	%PowerGeneration.text = "+%s" % Power.to_str(p.generation)
	%PowerUsage.visible = p.usage > 0
	%PowerUsage.text = "-%s" % Power.to_str(p.usage)
	%PowerTotal.text = "%s / %s" % [Power.to_str(p.total_usage), Power.to_str(p.total_generation)]
	%PowerTotal.add_theme_color_override(&"font_color", Color.RED if p.total_usage > p.total_generation else Color.GREEN)


func power_connect(target: GameObject) -> void:
	selected.power.connect_set(target.power)


func _on_power_connect(on: bool = false) -> void:
	ui.pop(Power)
	
	%PowerConnect.set_pressed_no_signal(on)
	
	if on:
		stack.push_back(power_connect)
		ui.push(Power, _on_power_connect)
	else:
		stack.pop_back()
