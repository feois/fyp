class_name NoisePollution
extends AreaEffect


func _process(_delta: float) -> void:
	super._process(_delta)
	visible = object.world.ui.noise_display


func apply(obj: GameObject) -> void: obj.noise += get_effect_to(obj.global_position)
func unapply(obj: GameObject) -> void: obj.noise -= get_effect_to(obj.global_position)


static func is_dangerous(noise_level: float) -> bool: return noise_level >= 1
static func is_cautious(noise_level: float) -> bool: return noise_level >= 0.5
