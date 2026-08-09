extends MeshInstance3D


@export var material: Material
@export var count: int


var size: Vector2i


func _ready() -> void: material_override = material


@warning_ignore("shadowed_variable")
func set_size(size: Vector2i) -> void:
	if size != self.size:
		self.size = size
		build()


func build() -> void:
	var n := size + Vector2i(count, count) * 2
	var offset = n * 0.5
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for x in range(1, n.x):
		mesh.surface_add_vertex(Vector3(offset.x - x, 0, -offset.y))
		mesh.surface_add_vertex(Vector3(offset.x - x, 0, +offset.y))
	
	for y in range(1, n.y):
		mesh.surface_add_vertex(Vector3(-offset.x, 0, offset.y - y))
		mesh.surface_add_vertex(Vector3(+offset.x, 0, offset.y - y))
	
	mesh.surface_end()
