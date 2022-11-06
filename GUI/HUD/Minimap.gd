extends TileMap

const GROUND = 0
const WALL = 1
const PLAYER = 2

# A reference to the UI node
onready var ui = get_parent()

var player_tile_pos: Vector2 # Tile pos of player displayed in the minimap

# Copies the layout of the given walls tilemap to the minimap tilemap
func update_minimap(walls: TileMap):
	# Do nothing if the walls tilemap is empty
	if not walls.get_used_cells(): return
	# Get the rect which defines the region of the tilemap that is in use
	var rect = walls.get_used_rect()
	# Loop over the used rect and place minimap tiles accordingly
	for x in range(rect.position.x, rect.position.x+rect.size.x):
		for y in range(rect.position.y, rect.position.y+rect.size.y):
			var tile = GROUND if walls.get_cell(x, y) == -1 else WALL
			set_cell(x, y, tile)
	# Update minimap UI element
	ui.set_minimap_dimensions()

# Sets the previous tile position to GROUND tile 
# and the new tile position to PLAYER tile
func set_player_tile(new_tile_pos: Vector2):
	if player_tile_pos: set_cell(player_tile_pos.x, player_tile_pos.y, GROUND)
	set_cell(new_tile_pos.x, new_tile_pos.y, PLAYER)
	player_tile_pos = new_tile_pos

# Updates the player tile position displayed in the minimap
func update_player_tile_pos(player_pos: Vector2, ceiling: TileMap):
	var actual_tile_pos = ceiling.world_to_map(player_pos)
	# Set player tile to the actual tile pos, if unobstructed
	if ceiling.get_cell(actual_tile_pos.x, actual_tile_pos.y) == -1:
		set_player_tile(actual_tile_pos)
	else:
		# If actual tile is obstructed, get the centre pos of the actual tile
		var offset = Vector2.ONE * cell_size/2
		var centre_pos = ceiling.map_to_world(actual_tile_pos) + offset
		# Get the direction from the centre of the tile to the player
		var direction = centre_pos.direction_to(player_pos)
		# Approximate direction and get the next tile in that direction 
		var next_tile_pos = actual_tile_pos + Utils.approximate_direction_4_ways(direction)
		# Set player tile to the next tile pos instead, if unobstructed
		if ceiling.get_cell(next_tile_pos.x, next_tile_pos.y) == -1:
			set_player_tile(next_tile_pos)
