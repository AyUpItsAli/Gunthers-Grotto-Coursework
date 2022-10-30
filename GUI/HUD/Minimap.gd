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
func update_player_pos(new_player_pos: Vector2, ceiling: TileMap):
	var new_tile_pos = ceiling.world_to_map(new_player_pos)
	if new_tile_pos == player_tile_pos: return
	
	# If new tile is unobstructed, set player tile here
	if ceiling.get_cell(new_tile_pos.x, new_tile_pos.y) == -1:
		set_player_tile(new_tile_pos)
	else:
		# If new tile is obstructed, get the centre pos of the new tile
		var offset = Vector2.ONE * ceiling.cell_size / 2
		var centre_pos = ceiling.map_to_world(new_tile_pos) + offset
		
		# Find the direction from the centre of the tile to the player
		var direction = centre_pos.direction_to(new_player_pos)
		
		# Get the next tile in the estimated direction
		var next_tile_pos: Vector2
		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				next_tile_pos = new_tile_pos + Vector2.LEFT
			else:
				next_tile_pos = new_tile_pos + Vector2.RIGHT
		else:
			if direction.y < 0:
				next_tile_pos = new_tile_pos + Vector2.UP
			else:
				next_tile_pos = new_tile_pos + Vector2.DOWN
		
		# Set the player tile at the next tile pos instead
		if ceiling.get_cell(next_tile_pos.x, next_tile_pos.y) == -1:
			set_player_tile(next_tile_pos)
