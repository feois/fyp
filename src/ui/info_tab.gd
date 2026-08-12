@tool
extends Control


@export var content: Control
@export var icon: Texture2D
@export var tooltip := &""

@onready var button := %Button as Button


func _ready() -> void:
	%Icon.texture = icon
	button.tooltip_text = tooltip


func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): %Icon.texture = icon


func _on_button_toggled(toggled_on: bool) -> void: content.visible = toggled_on
