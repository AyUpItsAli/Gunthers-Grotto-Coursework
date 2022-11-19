extends TileMap

func update_ground_layer():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			set_cell(x, y, Globals.GROUND)
