extends Area2D

var vector_rotation # Rotation applied to the push vector

func _ready():
	connect("area_entered", self, "on_area_entered")

# Randomises the rotation only when a new collision occurs
func on_area_entered(area):
	var neg_or_pos = -1 if randf() < 0.5 else 1
	vector_rotation = neg_or_pos * deg2rad(50)

# Get the direction in which to "push" in order to stop overlapping
func get_push_vector() -> Vector2:
	var push_vector = Vector2.ZERO
	var areas = get_overlapping_areas()
	if areas.size() > 0:
		var area: Area2D = areas[0]
		var direction = area.global_position.direction_to(global_position)
		# Rotate this direction by 45 degrees or -45 degrees
		push_vector = direction.rotated(vector_rotation)
	return push_vector
