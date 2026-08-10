class_name Power
extends GraphSet


@export var generation: float
@export var usage: float


var group_generation: float
var group_usage: float
var _generation: float
var _usage: float


func on_join(d: DisjointSet) -> void:
	var p := d as Power
	generation += p.generation
	usage += p.usage


func on_reset() -> void:
	_generation = 0
	_usage = 0
	update()


func update() -> void:
	var r := root() as Power
	r.group_generation += generation - _generation
	r.group_usage += usage - _usage
	_generation = generation
	_usage = usage
