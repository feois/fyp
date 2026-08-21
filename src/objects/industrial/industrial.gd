class_name Industrial
extends GameObject


@export var uneducated_production := 0
@export var educated_production := 0
@export var high_educated_production := 0
@export var standard_deviation := 0.0


func _ready() -> void:
	super._ready()
	if not is_preview: world.produce.connect(produce)


func produce() -> void:
	if not is_connected_to_main_road(): return
	if power and not power.is_sufficient(): return
	if water and not water.is_sufficient(): return
	
	for employee in workplace.employees:
		var i := 0
		
		match employee.education:
			Agent.EducationLevel.None: i = uneducated_production
			Agent.EducationLevel.Normal: i = educated_production
			Agent.EducationLevel.High: i = high_educated_production
		
		world.production += NormalDistribution.generate(i, i * standard_deviation) as int
