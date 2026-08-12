class_name GraphRenderer
extends MultiMeshInstance3D


@export var growth_rate := 100


func _ready() -> void: multimesh.visible_instance_count = 0


func alloc() -> int:
	var i := multimesh.visible_instance_count
	
	if i == multimesh.instance_count: multimesh.instance_count += growth_rate
	
	multimesh.visible_instance_count += 1
	
	return i


func dealloc(id: int) -> void:
	multimesh.set_instance_transform(id, multimesh.get_instance_transform(multimesh.visible_instance_count - 1))
	multimesh.visible_instance_count -= 1


func draw(id: int, from: Vector3, to: Vector3) -> void:
	var d := to - from
	var p := (from + to) / 2
	var b := Basis.looking_at(d.normalized(), Vector3.UP) * Basis(Vector3.RIGHT, -PI / 2)
	
	multimesh.set_instance_transform(id, Transform3D(b.scaled_local(Vector3(1, d.length(), 1)), p))


func draw_new(from: Vector3, to: Vector3) -> int:
	var id := alloc()
	draw(id, from, to)
	return id
