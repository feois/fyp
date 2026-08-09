extends GameObject


@export var rotate_speed: float

@onready var blades := $Blades as Node3D


func _process(delta: float) -> void:
	super._process(delta)
	
	blades.rotate_z(rotate_speed * delta)
