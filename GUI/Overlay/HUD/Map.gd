extends TileMap

# Constants
const PADDING = 30 # 30 extra tiles on each side of the map
const WALL = 0 # Tile ID for walls

func _unhandled_input(event):
	if event.is_action_pressed("toggle_map"):
		visible = not visible

# Updates the map layout to match the given tilemap
func update_map(walls: TileMap):
	# Do nothing if the tilemap is empty
	if not walls.get_used_cells(): return
	# Get the rect which defines the region of the tilemap that is in use
	var rect = walls.get_used_rect()
	# Defines start and end coords
	var start_x = rect.position.x
	var start_y = rect.position.y
	var end_x = rect.position.x+rect.size.x
	var end_y = rect.position.y+rect.size.y
	# Loop over used rect + padding
	for x in range(start_x-PADDING, end_x+PADDING):
		for y in range(start_y-PADDING, end_y+PADDING):
			# If x and y are outside the cave, set to a wall tile
			if x < start_x or x >= end_x or y < start_y or y >= end_y:
				set_cell(x, y, WALL)
			else: # ...otherwise set tile to match given tilemap
				var tile = -1 if walls.get_cell(x, y) == -1 else WALL
				set_cell(x, y, tile)
	update_bitmask_region()

# Updates the map's position so that the centre of the screen is positioned
# at the player's corresponding location within the world
func update_position(player_canvas_pos: Vector2, player_world_pos: Vector2):
	position = player_canvas_pos - (player_world_pos * scale)
