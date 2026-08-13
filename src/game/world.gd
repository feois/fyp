class_name World
extends Node3D


signal day_update
@warning_ignore("unused_signal")
signal road_update
@warning_ignore("unused_signal")
signal reapply_effects(object: GameObject)


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
@onready var agent_manager := %AgentManager as AgentManager
@onready var power_graph := %Graph/Power as GraphRenderer
@onready var water_graph := %Graph/Water as GraphRenderer


var start_date: int
var total_time: int
var total_days: int
var delta: float
var delta_day: float
var delta_time: float
var time_speed := TimeSpeed.Normal
var new_population := 0.0
var growth_rate := 1.0


func _ready() -> void:
	start_date = Time.get_unix_time_from_system() as int


@warning_ignore("shadowed_variable")
func _process(delta: float) -> void:
	self.delta = delta
	match time_speed:
		TimeSpeed.Normal: delta_time = delta
		TimeSpeed.Double: delta_time = delta * 2
		TimeSpeed.Quadruple: delta_time = delta * 4
	delta_day = delta_time / seconds_per_day
	total_time += (delta_day * 86400) as int
	
	@warning_ignore("integer_division")
	var days := total_time / 86400
	
	if days > total_days:
		total_days = days
		day_update.emit()
	
	new_population += delta_day * growth_rate


func get_time() -> int: return start_date + total_time
