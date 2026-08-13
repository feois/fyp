class_name Pollution
extends AreaEffect


func _process(_delta: float) -> void:
	super._process(_delta)
	visible = object.world.ui.pollution_display


func apply(obj: GameObject) -> void: obj.polluted += get_effect_to(obj.global_position)
func unapply(obj: GameObject) -> void: obj.polluted -= get_effect_to(obj.global_position)


static func is_dangerous(pollution_level: float) -> bool: return pollution_level >= 1
static func is_cautious(pollution_level: float) -> bool: return pollution_level >= 0.5
