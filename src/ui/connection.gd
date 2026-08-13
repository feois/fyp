class_name Connection
extends Control


signal pressed
signal delete


var object: GameObject


func setup() -> void:
	%Icon.texture = object.object_icon
	%Name.text = object.object_name


func _on_button_pressed() -> void: pressed.emit()


func _on_delete_pressed() -> void: delete.emit()
