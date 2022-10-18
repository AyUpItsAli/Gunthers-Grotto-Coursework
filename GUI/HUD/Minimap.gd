extends TileMap

const GROUND = 0
const ROCK = 1
const PLAYER = 2

# A reference to the UI node
onready var ui = get_parent()

var player_tile_pos: Vector2 # Player's current tile position

# Copies the layout of the given rock layer tilemap to the minimap tilemap
func update_minimap(rock_layer: TileMap):
	# Do nothing if the rock layer is empty
	if not rock_layer.get_used_cells(): return
	# Get the rect which defines the region of the tilemap that is in use
	var rect = rock_layer.get_used_rect()
	# Loop over the used rect and place minimap tiles accordingly
	for x in range(rect.position.x, rect.position.x+rect.size.x):
		for y in range(rect.position.y, rect.position.y+rect.size.y):
			var tile = GROUND if rock_layer.get_cell(x, y) == -1 else ROCK
			set_cell(x, y, tile)
	# Update minimap UI element
	ui.set_minimap_dimensions()

# Sets the player's previous tile position to a GROUND tile 
# and the new tile position to a PLAYER tile
func update_player_pos(new_tile_pos: Vector2):
	if player_tile_pos: set_cell(player_tile_pos.x, player_tile_pos.y, GROUND)
	set_cell(new_tile_pos.x, new_tile_pos.y, PLAYER)
	player_tile_pos = new_tile_pos
