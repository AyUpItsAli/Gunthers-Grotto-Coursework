extends TileMap

# Node references
onready var walls = get_parent().get_node("Walls")
onready var objects = get_parent().get_node("Objects")
onready var map = get_parent().get_parent().get_node("HUD/Map")

const CEILING = 0

# Places ceiling tiles above wall tiles
func update_ceiling_layer():
	for x in range(-1, Globals.CAVE_SIZE+1):
		for y in range(-1, Globals.CAVE_SIZE+1):
			var tile = -1 if walls.get_cell(x, y) == -1 else CEILING
			set_cell(x, y, tile)

# Destroys the tile at the given tile position and handles subsequent actions,
# as a result of the tile being removed.
func destroy_tile(tile_pos: Vector2, update: bool):
	var solid = get_cellv(tile_pos) != -1
	var out_of_bounds_x = 1 > tile_pos.x or tile_pos.x > Globals.CAVE_SIZE
	var out_of_bounds_y = 1 > tile_pos.y or tile_pos.y > Globals.CAVE_SIZE
	if not solid or out_of_bounds_x or out_of_bounds_y: return
	
	map.remove_tile(tile_pos)
	walls.set_cellv(tile_pos, -1)
	objects.destroy_gemstone_if_present(tile_pos)
	set_cellv(tile_pos, -1)
	if update:
		walls.update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
		update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)

# Called when an explosion detects the walls tilemap
func on_explosion(pos: Vector2):
	var tile_pos = world_to_map(pos)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var offset = Vector2(x, y)
			destroy_tile(tile_pos + offset, false)
	# Only update ONCE, after all tiles are removed
	walls.update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
	update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
