class_name Direction


enum Enum {
	Left,
	Right,
	Up,
	Down,
}


@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
const Null: Enum = -1
const Left := Enum.Left
const Right := Enum.Right
const Up := Enum.Up
const Down := Enum.Down
const values: Array[Direction.Enum] = [Left, Right, Up, Down]
const count := 4


static func vector(dir: Enum) -> Vector2i:
	match dir:
		Left: return Vector2i.LEFT
		Right: return Vector2i.RIGHT
		Up: return Vector2i.UP
		Down: return Vector2i.DOWN
	return Vector2i.ZERO


static func normalize(d: Vector2i) -> Enum:
	if absi(d.x) < absi(d.y): d.x = 0
	else: d.y = 0
	
	match d.sign():
		Vector2i.LEFT: return Left
		Vector2i.RIGHT: return Right
		Vector2i.UP: return Up
		Vector2i.DOWN: return Down
	
	return Null


static func opposite(dir: Enum) -> Enum:
	match dir:
		Left: return Right
		Right: return Left
		Up: return Down
		Down: return Up
	return Null


static func rotate_clockwise(dir: Enum) -> Enum:
	match dir:
		Left: return Up
		Up: return Right
		Right: return Down
		Down: return Left
	return Null


static func rotate_counterclockwise(dir: Enum) -> Enum:
	match dir:
		Left: return Down
		Down: return Right
		Right: return Up
		Up: return Left
	return Null


static func to_rotation(dir: Enum) -> GameObject.Rotation:
	match dir:
		Down: return GameObject.Rotation.None
		Left: return GameObject.Rotation.Clockwise
		Up: return GameObject.Rotation.Double
		Right: return GameObject.Rotation.Counterclockwise
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	return -1
