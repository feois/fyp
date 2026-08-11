class_name RoadGraph
extends DisjointSet


@export var main_road := false
@onready var road := owner as Road


var is_main_road := false


func neighbors():
	var roads: Array[RoadGraph] = []
	
	for dir in Direction.values:
		if road.has_direction(dir):
			var r := road.world.map.at(road.origin + Direction.vector(dir)) as Road
			if r: roads.append(r.graph)
	
	return roads


func on_join(d: DisjointSet) -> void:
	var graph := d as RoadGraph
	if graph: is_main_road = is_main_road or graph.is_main_road


func on_reset() -> void: is_main_road = main_road
