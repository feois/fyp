class_name Workplace
extends Node


@export var max_employee: int
@export var uneducated_pay: int
@export var educated_pay: int
@export var high_educated_pay: int
@export var standard_deviation: float

@onready var object := owner as GameObject


var employees: Array[Agent] = []


func _ready() -> void:
	object.world.day_update.connect(hire)


func hire() -> void:
	if employees.size() < max_employee:
		var employee := object.world.agent_manager.pop_jobless()
		
		if employee:
			employees.append(employee)
			employee.job = self
