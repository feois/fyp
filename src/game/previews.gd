class_name Previews
extends Node


var previews: Dictionary[GameObject, int] = {}
var valid := false


func empty() -> bool: return previews.is_empty()


func objects() -> Array[GameObject]:
	var o: Array[GameObject] = []
	o.assign(previews.keys())
	return o


@warning_ignore("shadowed_variable")
func mode(valid: bool) -> void:
	if valid == self.valid: return
	self.valid = valid
	for p in objects():
		if valid: p.preview_valid()
		else: p.preview_invalid()


func add(obj: GameObject) -> void:
	if obj == null or obj in previews: return
	previews[obj] = 0
	if valid: obj.preview_valid()
	else: obj.preview_invalid()


func remove(obj: GameObject, erase := true) -> void:
	if obj in previews:
		obj.clear_preview()
		if erase: previews.erase(obj)


func has(obj: GameObject) -> bool: return obj in previews


func clear(except: GameObject = null) -> void:
	if except in previews: previews.erase(except)
	else: except = null
	
	for p in objects(): remove(p, false)
	
	previews = {}
	
	if except: previews[except] = 0
