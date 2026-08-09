class_name ObjectSelector
extends MarginContainer


@onready var button := %Button as Button
@onready var icon := %Icon as TextureRect
@onready var obj_name := %Name as Label
@onready var price := %Price as Label

var object: GameObject


func setup() -> void:
	icon.texture = object.object_icon
	obj_name.text = object.object_name
	price.text = &"$ %d" % object.object_price
