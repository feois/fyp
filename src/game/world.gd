class_name World
extends Node3D


signal day_update
@warning_ignore("unused_signal")
signal road_update
@warning_ignore("unused_signal")
signal reapply_effects(object: GameObject)
@warning_ignore("unused_signal")
signal produce
@warning_ignore("unused_signal")
signal sales


enum TimeSpeed {
	Normal,
	Double,
	Quadruple,
}


@export var seconds_per_day: float
@export var categories: Array[Category]
@export var residential_scenes: Array[PackedScene]
@export var industrial_scenes: Array[PackedScene]
@export var commercial_scenes: Array[PackedScene]
@export var new_population := 0.0
@export var growth_rate := 1.0
@export var money := 0
@export var sales_tax := 0.0
@export var income_tax := 0.0

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
var residentials: Array[Residential] = []
var industrials: Array[Industrial] = []
var commercials: Array[Commercial] = []
var production: int
var total_sales: int


func _ready() -> void:
	start_date = Time.get_unix_time_from_system() as int
	
	for residential in residential_scenes:
		var r := residential.instantiate() as Residential
		r.world = self
		r.is_preview = true
		$Scenes.add_child(r)
		residentials.append(r)
	
	for industrial in industrial_scenes:
		var i := industrial.instantiate() as Industrial
		i.world = self
		i.is_preview = true
		$Scenes.add_child(i)
		industrials.append(i)
	
	for commercial in commercial_scenes:
		var c := commercial.instantiate() as Commercial
		c.world = self
		c.is_preview = true
		$Scenes.add_child(c)
		commercials.append(c)


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
		
		production = 0
		total_sales = 0
		produce.emit()
		sales.emit()
		
		var valid_sales := mini(production, total_sales)
		
		money += (valid_sales * sales_tax) as int
		
		for agent in agent_manager.agents:
			if agent.job:
				money += (agent.income * income_tax / 30) as int
	
	new_population += delta_day * growth_rate


func get_time() -> int: return start_date + total_time
