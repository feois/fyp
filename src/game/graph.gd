class_name GraphRenderer
extends MultiMeshInstance3D


@export var growth_rate := 100

var ids: Dictionary[Transform3D, int] = {}


func _ready() -> void: multimesh.visible_instance_count = 0


func count() -> int: return multimesh.visible_instance_count


func alloc() -> int:
	var n := count()
	
	if n == multimesh.instance_count: multimesh.instance_count += growth_rate
	
	multimesh.visible_instance_count += 1
	
	return n


func dealloc(id: int) -> void:
	if id < count():
		multimesh.set_instance_transform(id, multimesh.get_instance_transform(count() - 1))
		multimesh.visible_instance_count -= 1


static func get_line_transform(from: Vector3, to: Vector3) -> Transform3D:
	if from > to: var v := from; from = to; to = v
	var d := to - from
	var p := (from + to) / 2
	var b := Basis.looking_at(d.normalized(), Vector3.UP) * Basis(Vector3.RIGHT, -PI / 2)
	return Transform3D(b.scaled_local(Vector3(1, d.length(), 1)), p)


func draw_line(from: Vector3, to: Vector3) -> void:
	var t := get_line_transform(from, to)
	var id: int
	
	if ids.has(t): id = ids[t]
	else:
		id = alloc()
		ids[t] = id
	
	multimesh.set_instance_transform(id, t)


func remove_line(from: Vector3, to: Vector3) -> void:
	var t := get_line_transform(from, to)
	
	if count() > 0 and ids.has(t):
		var id := ids[t]
		
		ids[multimesh.get_instance_transform(count() - 1)] = id
		ids.erase(t)
		
		dealloc(id)
