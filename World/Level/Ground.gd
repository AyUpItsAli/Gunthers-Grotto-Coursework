extends TileMap

# Node references
onready var walls = get_parent().get_node("Walls")

# Tile references
const NAVABLE = 0
const NON_NAVABLE = 1

func update_ground_layer():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			if walls.get_cell(x, y) == -1: # If empty, place navable...
				set_cell(x, y, NAVABLE)
			else: # Otherwise, place non-navable
				set_cell(x, y, NON_NAVABLE)
