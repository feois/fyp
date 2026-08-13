class_name Agent
extends Object


enum EducationLevel {
	None,
	Normal,
	High,
}


var id: int
var education := EducationLevel.None
var job: Workplace
var income: int


func update_income() -> void:
	if not job: income = 0; return
	
	match education:
		EducationLevel.None: income = job.uneducated_pay
		EducationLevel.Normal: income = job.educated_pay
		EducationLevel.High: income = job.high_educated_pay
	
	income = NormalDistribution.generate(income, job.standard_deviation) as int
