extends TileMap

const SELECTED = 0
const MAX_DISTANCE = 20 # Maximum distance from a tile to be able to mine it

onready var walls = get_parent().get_node("Walls")
onready var objects = get_parent().get_node("Objects")
onready var ceiling = get_parent().get_node("Ceiling")

var player: Player
var player_tile: Vector2
var tile_selected: bool
var selected_tile: Vector2

func initialise_mining_grid():
	if objects.player_exists():
		player = objects.get_player()
		player.connect("pickaxe_used", self, "destroy_selected_tile")

func _process(delta):
	if player and player.equipped == player.Tools.PICKAXE:
		update_selected_tile()
	elif tile_selected:
		deselect_tile()

func deselect_tile():
	set_cellv(selected_tile, -1)
	selected_tile = Vector2.ZERO
	tile_selected = false

func select_tile(tile_pos: Vector2):
	set_cellv(selected_tile, -1)
	set_cellv(tile_pos, SELECTED)
	selected_tile = tile_pos
	tile_selected = true

func is_solid_tile(x, y):
	return ceiling.get_cell(x, y) != -1

func get_player_tile_pos() -> Vector2:
	var actual_tile_pos = world_to_map(player.position)
	# Return the actual tile pos, if it's not solid
	if not is_solid_tile(actual_tile_pos.x, actual_tile_pos.y):
		player_tile = actual_tile_pos
	else:
		# If actual tile is solid, get the centre pos of the actual tile
		var offset = Vector2.ONE * cell_size / 2
		var centre_pos = map_to_world(actual_tile_pos) + offset
		# Get the direction from the centre of the tile to the player
		var direction = centre_pos.direction_to(player.position)
		# Approximate direction and get the next tile in that direction 
		var next_tile_pos = actual_tile_pos + Utils.approximate_direction_4_ways(direction)
		# Return the next tile pos instead, if it's not solid
		if not is_solid_tile(next_tile_pos.x, next_tile_pos.y):
			player_tile = next_tile_pos
	return player_tile

func update_selected_tile():
	# Get the player's current tile pos and the tile hovered over by the mouse
	var player_tile_pos = get_player_tile_pos()
	var mouse_tile_pos = world_to_map(get_global_mouse_position())
	# Get the direction from the current tile to the hovered over tile
	var exact_direction = player_tile_pos.direction_to(mouse_tile_pos)
	var direction = Utils.approximate_direction_8_ways(exact_direction)
	# Get the next tile in this direction.
	# This is the tile the user wants to select.
	var tile_pos = player_tile_pos + direction
	
	# Check if the tile is out of bounds
	var out_of_bounds = (1 > tile_pos.x or tile_pos.x >= Globals.CAVE_SIZE-1
						or 1 > tile_pos.y or tile_pos.y >= Globals.CAVE_SIZE-1)
	# Check if the tile is solid (otherwise there is nothing to mine)
	var solid = is_solid_tile(tile_pos.x, tile_pos.y)
	# Check if the tile is blocked from the player by its neighbouring tiles
	var blocked = (is_solid_tile(tile_pos.x - direction.x, tile_pos.y)
					and is_solid_tile(tile_pos.x, tile_pos.y - direction.y))
	# Get the closest edge or vertex of the tile,
	# and store the distance from the player to this point
	var offset = (Vector2.ONE - direction.normalized()) * cell_size/2
	var closest_edge_or_vertex = map_to_world(tile_pos) + offset
	var distance = player.position.distance_to(closest_edge_or_vertex)
	
	# If the tile is not out of bounds, solid, not blocked from the player,
	# and the distance from the player to the closest edge or vertex is less
	# than the maximum distance, the tile can be selected...
	if not out_of_bounds and solid and not blocked and distance <= MAX_DISTANCE:
		select_tile(tile_pos)
	else: # ... otherwise, ensure no tiles are selected
		deselect_tile()

func destroy_selected_tile():
	if not tile_selected: return
	ceiling.destroy_tile(selected_tile, true)
