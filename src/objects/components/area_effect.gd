class_name AreaEffect
extends Area3D


@export var level := 1
@export var height := 1.0
@export var radius := 1.0

@onready var object := owner as GameObject

var radius_cache := 1.0


func _ready() -> void:
	visible = false
	if not object.is_preview: object.world.reapply_effects.connect(apply)


func _process(_delta: float) -> void:
	if radius != radius_cache:
		var cylinder := CylinderShape3D.new()
		cylinder.radius = radius
		$CollisionShape3D.shape = cylinder
		$MeshInstance3D.scale = Vector3(radius, 1, radius)
		radius_cache = radius


func get_effect(distance: float) -> float:
	var attenuation := distance / (3 + 2 * level)
	attenuation *= attenuation
	attenuation += 1
	return level / attenuation


func get_effect_to(pos: Vector3) -> float: return get_effect(object.global_position.distance_to(pos))


@warning_ignore("unused_parameter")
func apply(obj: GameObject) -> void: pass
@warning_ignore("unused_parameter")
func unapply(obj: GameObject) -> void: pass


func _on_body_entered(body: Node3D) -> void:
	if object.is_preview: return
	
	var obj := body as GameObject
	
	if obj: apply(obj)


func _on_body_exited(body: Node3D) -> void:
	if object.is_preview: return
	
	var obj := body as GameObject
	
	if obj: unapply(obj)
