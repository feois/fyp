class_name Power
extends GraphSet


@export var generation: float
@export var usage: float

@onready var object := owner as GameObject


var _group_generation: float
var _group_usage: float
var _generation: float
var _usage: float

var total_generation: float:
	get: return (root() as Power)._group_generation
var total_usage: float:
	get: return (root() as Power)._group_usage


func on_reset() -> void:
	_generation = 0
	_usage = 0
	_group_generation = 0
	_group_usage = 0
	update()


func on_join(d: DisjointSet) -> void:
	var p := d as Power
	_group_generation += p._group_generation
	_group_usage += p._group_usage


func on_connect(g: GraphSet) -> void:
	var p := g as Power
	object.world.power_graph.draw_line(object.global_position, p.object.global_position)


func on_disconnect(g: GraphSet) -> void:
	var p := g as Power
	object.world.power_graph.remove_line(object.global_position, p.object.global_position)


func update() -> void:
	var r := root() as Power
	r._group_generation += generation - _generation
	r._group_usage += usage - _usage
	_generation = generation
	_usage = usage


func is_sufficient() -> bool:
	var r := root() as Power
	return r._group_usage <= r._group_generation


static func to_str(power: float) -> String:
	var kWh := power
	var MWh := kWh / 1000
	var GWh := MWh / 1000
	
	if GWh > 1: return "%.2f GWh" % GWh
	if MWh > 1: return "%.2f MWh" % MWh
	return "%.2f kWh" % kWh
