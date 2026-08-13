class_name Residential
extends GameObject


@export var capacity: int

var agents: Array[Agent] = []


func process() -> void:
	var p := world.new_population as int
	
	for i in range(mini(capacity - agents.size(), p)):
		populate()
		world.new_population -= 1


func populate() -> void: agents.append(world.agent_manager.create())
