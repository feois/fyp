class_name Water
extends GraphSet


@export var supply: float
@export var usage: float

@onready var object := owner as GameObject


var _group_supply: float
var _group_usage: float
var _supply: float
var _usage: float

var total_supply: float:
	get: return (root() as Water)._group_supply
var total_usage: float:
	get: return (root() as Water)._group_usage


func on_reset() -> void:
	_supply = 0
	_usage = 0
	_group_supply = 0
	_group_usage = 0
	update()


func on_join(d: DisjointSet) -> void:
	var w := d as Water
	_group_supply += w._group_supply
	_group_usage += w._group_usage


func on_connect(g: GraphSet) -> void:
	var w := g as Water
	object.world.water_graph.draw_line(object.global_position, w.object.global_position)


func on_disconnect(g: GraphSet) -> void:
	var w := g as Water
	object.world.water_graph.remove_line(object.global_position, w.object.global_position)


func update() -> void:
	var r := root() as Water
	r._group_supply += supply - _supply
	r._group_usage += usage - _usage
	_supply = supply
	_usage = usage


static func to_str(water: float) -> String:
	var L := water
	var kL := L / 1000
	var ML := kL / 1000
	
	if ML > 1: return "%.2f ML" % ML
	if kL > 1: return "%.2f kL" % kL
	return "%.2f L" % L
