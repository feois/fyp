class_name GraphSet
extends DisjointSet


var connections: Dictionary[GraphSet, Variant]


func neighbors(): return connections.keys()


func reconnect() -> void:
	for g in connections.keys(): connect_set(g)


func connect_set(g: GraphSet) -> void:
	if g in connections: return
	connections[g] = null
	g.connections[self] = null
	join(g)
	on_connect(g)


@warning_ignore("unused_parameter")
func on_connect(g: GraphSet) -> void: pass


func disconnect_set(g: GraphSet) -> void:
	if g not in connections: return
	connections.erase(g)
	g.connections.erase(self)
	
	var nodes := [self]
	var visited: Dictionary[GraphSet, Variant] = {}
	
	while not nodes.is_empty():
		var n := nodes.pop_back() as GraphSet
		
		if n == g: return
		
		for node in n.connections.keys():
			if node in visited: continue
			visited[node] = null
			nodes.push_back(node)
	
	on_disconnect(g)


@warning_ignore("unused_parameter")
func on_disconnect(g: GraphSet) -> void: pass
