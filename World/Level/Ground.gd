extends TileMap

# Node references
onready var walls = get_parent().get_node("Walls")

# Tile references
const GROUND = 0

func update_ground_layer():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			if walls.get_cell(x, y) == walls.WALL:
				set_cell(x, y, 1)
			else:
				set_cell(x, y, GROUND)
