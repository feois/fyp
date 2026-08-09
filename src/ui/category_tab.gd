class_name CategoryTab
extends MarginContainer


@export var animation := 0.0

@onready var button := %Button as Button
@onready var content := %Content as Control
@onready var category_icon := %Icon as TextureRect
@onready var category_name := %Name as Label

var category: Category
var tween: Tween
var mouse := false
var state := false
var objects: Array[GameObject] = []


func _ready() -> void: content.custom_maximum_size.x = -1 if button.button_pressed else 0


func setup() -> void:
	category_icon.texture = category.icon
	category_name.text = category.name
	for object in category.objects: objects.append(object.instantiate())


func _on_button_toggled(toggled_on: bool) -> void:
	content.custom_maximum_size.x = -1
	
	var expand := mouse or toggled_on
	var x := content.get_minimum_size().x
	var offset := 0.0
	
	if expand == state: return
	
	state = expand
	
	if tween:
		offset = minf(animation - tween.get_total_elapsed_time(), 0)
		tween.kill()
	
	tween = create_tween()
	
	(tween.tween_property(content, ^"custom_maximum_size:x", x if expand else 0.0, animation)
		.from(0.0 if expand else x)
		.set_trans(Tween.TRANS_CUBIC)
		.set_ease(Tween.EASE_IN_OUT))
	
	if expand: tween.tween_callback(func () -> void: content.custom_maximum_size.x = -1)
	
	tween.custom_step(offset)


func _on_button_mouse_entered() -> void:
	mouse = true
	_on_button_toggled(button.button_pressed)


func _on_button_mouse_exited() -> void:
	mouse = false
	_on_button_toggled(button.button_pressed)
