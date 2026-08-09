@tool
extends SubViewport


@export var offset: Vector3
@export var rotation: Vector3
@export var zoom := 1.0
@export var path: StringName


func _ready() -> void:
	if not Engine.is_editor_hint():
		await RenderingServer.frame_post_draw
		var image := get_texture().get_image()
		image.save_png("res://%s.png" % path)
		get_tree().quit()


func _process(_delta: float) -> void:
	$Pivot.position = offset
	$Pivot.rotation_degrees = rotation
	$Pivot/Camera.size = zoom
