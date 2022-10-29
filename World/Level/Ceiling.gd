extends TileMap

# Node references
onready var walls = get_parent().get_node("Walls")

const CEILING = 0

# Places ceiling tiles above wall tiles
func update_ceiling_layer():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			var tile = -1 if walls.get_cell(x, y) == -1 else CEILING
			set_cell(x, y, tile)
