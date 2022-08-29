extends TileMap

# Node references
onready var rock_layer = get_parent().get_node("RockLayer")

# Tile references
const TOP = {
	"single": 0,
	"left": 1,
	"middle": 2,
	"right": 3,
}
const BOTTOM = {
	"single": 4,
	"left": 5,
	"middle": 6,
	"right": 7,
}
const CORNER_LEFT = 8
const CORNER_MIDDLE = 9
const CORNER_RIGHT = 10
const EDGE_CORNER_LEFT = 11
const EDGE_CORNER_RIGHT = 12

# Sets all tiles to empty
func clear_walls():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			set_cell(x, y, -1)

# Returns whether the tile is rock or not
func is_tile_rock(x, y) -> bool:
	return rock_layer.get_cell(x, y) == rock_layer.ROCK

# Places a wall at the specified coords, but only if there isn't a wall there already
func place_wall_if_empty(x, y, tile):
	if get_cell(x, y) != -1: return
	set_cell(x, y, tile)

# Places a wall in the specified corner
func place_wall_in_corner(corner_x, corner_y, default_variant):
	# Check tiles around this tile
	# Store whether these tiles are rock or not
	var below = is_tile_rock(corner_x, corner_y+1)
	var below_left = is_tile_rock(corner_x-1, corner_y+1)
	var below_right = is_tile_rock(corner_x+1, corner_y+1)
	var left = is_tile_rock(corner_x-1, corner_y)
	var right = is_tile_rock(corner_x+1, corner_y)
	var above_left = is_tile_rock(corner_x-1, corner_y-1)
	var above_right = is_tile_rock(corner_x+1, corner_y-1)
	
	# If there is rock below this tile
	# Also check diagonally to the left and right
	if below and below_left and below_right:
		# If both neighbours are empty,
		# Confirm that there is rock above the two neighbours
		if not (left or right) and (above_left and above_right):
			# If so, place a pair of middle walls (top and bottom halves)
			place_wall_if_empty(corner_x, corner_y-1, TOP["middle"])
			set_cell(corner_x, corner_y, BOTTOM["middle"])
		else:
			# Otherwise, place a pair of whatever the original variant was
			place_wall_if_empty(corner_x, corner_y-1, TOP[default_variant])
			set_cell(corner_x, corner_y, BOTTOM[default_variant])
	
	# If it is empty below this tile
	else:
		# If both neighbours are empty
		if not (left or right):
			# If both neighbours have rock above them, place a middle corner
			if above_left and above_right:
				place_wall_if_empty(corner_x, corner_y-1, TOP["middle"])
				set_cell(corner_x, corner_y, CORNER_MIDDLE)
			# If only the left neighbour has rock above it, place a left edge corner
			elif above_left:
				place_wall_if_empty(corner_x, corner_y-1, TOP["right"])
				set_cell(corner_x, corner_y, EDGE_CORNER_LEFT)
			# If only the right neighbour has rock above it, place a right edge corner
			elif above_right:
				place_wall_if_empty(corner_x, corner_y-1, TOP["left"])
				set_cell(corner_x, corner_y, EDGE_CORNER_RIGHT)
		# If only the left neighbour is rock, place a right corner
		elif left:
			place_wall_if_empty(corner_x, corner_y-1, TOP["left"])
			set_cell(corner_x, corner_y, CORNER_RIGHT)
		# If only the right neighbour is rock, place a left corner
		else:
			place_wall_if_empty(corner_x, corner_y-1, TOP["right"])
			set_cell(corner_x, corner_y, CORNER_LEFT)

# Updates the walls layer to match the rock layer
func update_walls_layer():
	# Clear the tilemap
	clear_walls()
	
	# Place wall tiles
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			# Check all rock tiles that have an empty tile below them.
			if is_tile_rock(x, y) and not is_tile_rock(x, y+1):
				# Store if neighbouring tiles are also rock
				var left = is_tile_rock(x-1, y)
				var right = is_tile_rock(x+1, y)

				# Place top wall inside of this tile in the correct orientation
				# Place bottom wall below this tile in the correct orientation
				if left and right: # Both sides
					place_wall_if_empty(x, y, TOP["middle"])
					set_cell(x, y+1, BOTTOM["middle"])
				elif left: # Just left
					place_wall_if_empty(x, y, TOP["right"])
					set_cell(x, y+1, BOTTOM["right"])
				elif right: # Just right
					place_wall_if_empty(x, y, TOP["left"])
					set_cell(x, y+1, BOTTOM["left"])
				else: # Empty either side
					place_wall_if_empty(x, y, TOP["single"])
					set_cell(x, y+1, BOTTOM["single"])
				
				# Check the tiles below the left and right neighbours
				# Store whether these tiles are rock or not
				var below_left = is_tile_rock(x-1, y+1)
				var below_right = is_tile_rock(x+1, y+1)
				
				# If the left neighbour is rock, and there is rock below it,
				# Then this is a corner, so place a wall in the corner
				if left and below_left:
					place_wall_in_corner(x-1, y+1, "left")
				# If the right neighbour is rock, and there is rock below it,
				# Then this is also a corner, so place a wall in the corner
				if right and below_right:
					place_wall_in_corner(x+1, y+1, "right")
