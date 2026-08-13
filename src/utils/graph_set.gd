class_name GraphSet
extends DisjointSet


var connections: Dictionary[GraphSet, Variant]


func neighbors(): return connections.keys()


func is_connected_to(g: GraphSet) -> bool: return connections.has(g)


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


static func raw_search_connection(a: GraphSet, b: GraphSet) -> bool:
	var nodes := [a]
	var visited: Dictionary[GraphSet, Variant] = {}
	
	while not nodes.is_empty():
		var n := nodes.pop_front() as GraphSet # BFS (pop_back for DFS)
		
		if n == b: return true
		
		for node in n.connections:
			if node in visited: continue
			visited[node] = null
			nodes.push_back(node)
	
	return false


func disconnect_set(g: GraphSet) -> void:
	if g not in connections: return
	
	connections.erase(g)
	g.connections.erase(self)
	
	if not raw_search_connection(self, g):
		mark_dirty()
		g.mark_dirty()
		rebuild()
		g.rebuild()
	
	on_disconnect(g)


func disconnect_all() -> void:
	for c in connections:
		c.mark_dirty()
		c.connections.erase(self)
	for c in connections: (c.rebuild())
	for c in connections: on_disconnect(c)
	connections.clear()


@warning_ignore("unused_parameter")
func on_disconnect(g: GraphSet) -> void: pass
