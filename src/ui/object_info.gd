extends Control


const GOOD := Color.GREEN
const BAD := Color.RED
const DANGEROUS := Color.YELLOW


@export var ui: UI

@onready var camera := ui.world.camera

var hovered: GameObject
var selected: GameObject
var stack: Array[Callable] = [select]


func _ready() -> void:
	visible = false
	for content in %Content.get_children(): content.visible = false


func _process(_delta: float) -> void:
	if get_viewport().gui_get_hovered_control() or ui.building or ui.destruction_mode: hover(null)
	else:
		hover(camera.project_mouse(1 << 2) as GameObject)
		
		if Input.is_action_just_pressed(&"Select", true): stack.back().call(hovered)
	
	if selected:
		if %Info.visible: info()
		if %Power.visible: power()


func set_color(label: Label, color: Color) -> void: label.add_theme_color_override(&"font_color", color)


func hover(object: GameObject) -> void:
	if object == hovered: return
	if hovered: hovered.deselect()
	hovered = null
	if (object and object.is_preview) or object == selected: return
	hovered = object
	if hovered: hovered.hover()


func select(object: GameObject = null) -> void:
	if object == selected: return
	if object == hovered: hover(null)
	if selected: selected.deselect()
	#ui.pop(self)
	ui.cancel_all()
	selected = object
	if object:
		selected.select()
		visible = true
		get_parent_control().notification(Container.NOTIFICATION_SORT_CHILDREN)
		camera.center_at(selected.global_position)
		%Tabs/Info.button.button_pressed = true
		%Tabs/Power.visible = object.power != null
		for connection in %PowerConnections.get_children(): connection.queue_free()
		ui.push(self, select)
	else:
		%Power.visible = false
		visible = false


func new_connection() -> Connection: return preload("res://src/ui/connection.tscn").instantiate()


func info() -> void:
	%Name.text = selected.object_name
	%Icon.texture = selected.object_icon
	
	if selected.power:
		%Status/Power.visible = true
		%Status/Power.text = "Power: %s" % ("OK" if selected.power.is_sufficient() else "Insufficient!")
		set_color(%Status/Power, GOOD if selected.power.is_sufficient() else BAD)
	else: %Status/Power.visible = false
	
	if selected.water:
		%Status/Water.visible = true
		%Status/Water.text = "Water: %s" % ("OK" if selected.water.is_sufficient() else "Insufficient!")
		set_color(%Status/Water, GOOD if selected.water.is_sufficient() else BAD)
	else: %Status/Water.visible = false
	
	%Status/Pollution.text = "Pollution level: %.2f" % selected.polluted
	set_color(%Status/Pollution,
		BAD if Pollution.is_dangerous(selected.polluted)
		else (DANGEROUS if Pollution.is_cautious(selected.polluted) else GOOD),
	)
	
	%Status/Noise.text = "Noise level: %.2f" % selected.noise
	set_color(%Status/Noise,
		BAD if NoisePollution.is_dangerous(selected.noise)
		else (DANGEROUS if NoisePollution.is_cautious(selected.noise) else GOOD),
	)


func power() -> void:
	var p := selected.power
	%PowerGeneration.visible = p.generation > 0
	%PowerGeneration.text = "+%s" % Power.to_str(p.generation)
	%PowerUsage.visible = p.usage > 0
	%PowerUsage.text = "-%s" % Power.to_str(p.usage)
	%PowerTotal.text = "%s / %s" % [Power.to_str(p.total_usage), Power.to_str(p.total_generation)]
	%PowerTotal.add_theme_color_override(&"font_color", GOOD if p.is_sufficient() else BAD)
	ui.power_display = true
	if %PowerConnections.get_child_count() < p.connections.size():
		for c in %PowerConnections.get_children(): c.queue_free()
		
		for c in p.connections:
			var cp := c as Power
			var connection := new_connection()
			
			connection.object = cp.object
			connection.setup()
			connection.pressed.connect(
				func () -> void:
					select(cp.object)
			)
			connection.delete.connect(
				func () -> void:
					p.disconnect_set(cp)
					connection.queue_free()
			)
			
			%PowerConnections.add_child(connection)


func power_connect(target: GameObject) -> void:
	if not target: return
	if not target.power: ui.notify("This object does not have a power component!"); return
	if selected.power.is_connected_to(target.power): ui.notify("Already connected!"); return
	
	selected.power.connect_set(target.power)
	_on_power_connect()


func _on_power_connect(on: bool = false) -> void:
	ui.pop(Power)
	
	%PowerConnect.set_pressed_no_signal(on)
	
	if on:
		stack.push_back(power_connect)
		ui.push(Power, _on_power_connect)
	else:
		stack.pop_back()


func _on_destroy_pressed() -> void:
	var obj := selected
	select(null)
	obj.destroy()
