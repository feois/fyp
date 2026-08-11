class_name World
extends Node3D


@warning_ignore("unused_signal")
signal road_update


enum TimeSpeed {
	Normal,
	Double,
	Quadruple,
}


@export var seconds_per_day: float
@export var categories: Array[Category]

@export var ui: UI

@onready var map := %Map as Map
@onready var previews := %Previews as Previews
@onready var camera := %Camera as IsometricCamera


var delta: float
var delta_day: float
var delta_time: float
var time_speed := TimeSpeed.Normal


@warning_ignore("shadowed_variable")
func _process(delta: float) -> void:
	self.delta = delta
	match time_speed:
		TimeSpeed.Normal: delta_time = delta
		TimeSpeed.Double: delta_time = delta * 2
		TimeSpeed.Quadruple: delta_time = delta * 4
	delta_day = delta_time / seconds_per_day
