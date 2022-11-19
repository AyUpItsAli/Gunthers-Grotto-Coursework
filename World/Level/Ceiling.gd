extends TileMap

# Node references
onready var walls = get_parent().get_node("Walls")
onready var objects = get_parent().get_node("Objects")
onready var map = Overlay.get_node("HUD/Map")

# Places ceiling tiles above wall tiles.
func update_ceiling_layer():
	for x in range(-1, Globals.CAVE_SIZE+1):
		for y in range(-1, Globals.CAVE_SIZE+1):
			var tile = -1 if walls.get_cell(x, y) == -1 else Globals.CEILING
			set_cell(x, y, tile)

# Returns the tile family which the given id is part of, found in Globals.TILE_FAMILIES.
# Returns {} if no family was found.
# Note: "tile" is checked against the Ceiling tileset of each family.
func get_tile_family(tile: int) -> Dictionary:
	for family in Globals.TILE_FAMILIES.values():
		if tile in family.ceiling:
			return family
	return {}

# Returns a dictionary of the next ceiling and wall tile variants,
# from the tile family of the given tile id.
# "current_tile" MUST be from the Ceiling tileset.
func get_next_damaged_tiles(current_tile: int) -> Dictionary:
	var family = get_tile_family(current_tile)
	if family:
		var next = family.ceiling.find(current_tile) + 1
		if next >= 0 and next < family.ceiling.size():
			return {ceiling = family.ceiling[next], walls = family.walls[next]}
	return {}

# Sets the given tile pos to the next tile variant in the corresponding
# tile family, for both the ceiling and walls layers.
# If there are no next tiles, the tile is removed in both tilemaps, as well as the map,
# and the objects node is triggered to destroy any gemstones present.
func damage_tile(tile_pos: Vector2, update: bool):
	var current_id = get_cellv(tile_pos)
	var out_of_bounds_x = 1 > tile_pos.x or tile_pos.x > Globals.CAVE_SIZE
	var out_of_bounds_y = 1 > tile_pos.y or tile_pos.y > Globals.CAVE_SIZE
	# If tile is empty, or out of bounds, do nothing
	if current_id == -1 or out_of_bounds_x or out_of_bounds_y: return
	
	var next_tiles = get_next_damaged_tiles(current_id)
	# If there are next tiles, update ceiling and walls layers with new tiles...
	if next_tiles:
		set_cellv(tile_pos, next_tiles.ceiling)
		walls.set_cellv(tile_pos, next_tiles.walls)
	else: # ...otherwise, remove the tile from the ceiling and walls layers
		set_cellv(tile_pos, -1)
		walls.set_cellv(tile_pos, -1)
		map.set_cellv(tile_pos, -1) # Update the map only when the tile is destroyed
		objects.destroy_gemstone_if_present(tile_pos) # Destroy gemstone is there is one
	
	if update:
		update_bitmask_area(tile_pos)
		walls.update_bitmask_area(tile_pos)
		map.update_bitmask_area(tile_pos)

# Called when an explosion detects the walls tilemap.
# "pos" is the centre of the explosion.
func on_explosion(pos: Vector2):
	var tile_pos = world_to_map(pos)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var offset = Vector2(x, y)
			damage_tile(tile_pos + offset, false)
	# Only update bitmasks, after all tiles are damaged
	update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
	walls.update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
	map.update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
