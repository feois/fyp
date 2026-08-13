class_name DisjointSet
extends Node


var parent := self
var size := 1


func _ready() -> void: reset()


func is_root() -> bool: return self == self.parent


func is_valid() -> bool: return root() != null


func root() -> DisjointSet:
	var n := self
	while not n.is_root():
		if not n.parent: return null
		var p := n.parent
		var gp := p.parent
		n.parent = gp
		n = p
	return n


func join(d: DisjointSet) -> bool:
	var x := root()
	var y := d.root()
	
	if x == y: return false
	
	if x.size < y.size:
		x = d.root()
		y = root()
	
	y.size += x.size
	x.parent = y
	y.on_join(x)
	return true


@warning_ignore("unused_parameter")
func on_join(d: DisjointSet) -> void: pass


func on_reset() -> void: pass


func reset() -> void:
	parent = self
	size = 1
	on_reset()


func neighbors(): return []


func mark_dirty() -> void:
	var r := root()
	if r: r.parent = null


func rebuild() -> void:
	if is_valid(): return
	
	var nodes := [self]
	
	reset()
	
	while not nodes.is_empty():
		var node := nodes.pop_back() as DisjointSet
		
		for n in node.neighbors():
			if n.is_root(): continue
			n.reset()
			nodes.push_back(n)
	
	nodes.push_back(self)
	
	while not nodes.is_empty():
		var node := nodes.pop_front() as DisjointSet
		
		for n in node.neighbors():
			if node.join(n):
				nodes.push_back(n)
