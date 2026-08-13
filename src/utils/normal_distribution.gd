class_name NormalDistribution


static func generate(mean: float, standard_deviation: float) -> float:
	var x := randf(); if x == 0: x = 1
	var y := randf()
	var z := sqrt(-2 * log(x)) * cos(2 * PI * y)

	return mean + standard_deviation * z;
