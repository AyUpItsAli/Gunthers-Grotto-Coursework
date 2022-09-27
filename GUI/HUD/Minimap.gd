extends TileMap

const GROUND = 0
const ROCK = 1
const PLAYER = 2

var player_tile_pos: Vector2 # Player's current tile position

# Copies the layout of the given rock layer tilemap to the minimap tilemap
func update_minimap(rock_layer: TileMap):
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			var tile = GROUND if rock_layer.get_cell(x, y) == -1 else ROCK
			
			set_cell(x, y, tile)

# Sets the player's previous tile position to a GROUND tile 
# and the new tile position to a PLAYER tile
func update_player_pos(new_tile_pos: Vector2):
	if player_tile_pos: set_cell(player_tile_pos.x, player_tile_pos.y, GROUND)
	set_cell(new_tile_pos.x, new_tile_pos.y, PLAYER)
	player_tile_pos = new_tile_pos
