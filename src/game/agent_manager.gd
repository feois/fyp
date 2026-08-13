class_name AgentManager
extends Node


var agents: Array[Agent] = []
var jobless: Array[Agent] = []


func create() -> Agent:
	var agent := Agent.new()
	
	agent.id = agents.size()
	agents.append(agent)
	jobless.append(agent)
	
	return agent


func destroy(agent: Agent) -> void:
	if agent and agents.get(agent.id) != agent: return
	
	var last := agents.back() as Agent
	
	last.id = agent.id
	agents[agent.id] = last
	agents.pop_back()
	if agent.job: agent.job.employees.erase(agent)
	else: jobless.erase(agent)
	agent.free()


func pop_jobless() -> Agent: return null if jobless.is_empty() else jobless.pop_back()
