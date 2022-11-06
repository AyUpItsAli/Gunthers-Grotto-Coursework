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
	set_cell(selected_tile.x, selected_tile.y, -1)
	selected_tile = Vector2.ZERO
	tile_selected = false

func select_tile(tile_pos: Vector2):
	set_cell(selected_tile.x, selected_tile.y, -1)
	set_cell(tile_pos.x, tile_pos.y, SELECTED)
	selected_tile = tile_pos
	tile_selected = true

func get_player_tile_pos() -> Vector2:
	var actual_tile_pos = world_to_map(player.position)
	# Return the actual tile pos, if unobstructed
	if ceiling.get_cell(actual_tile_pos.x, actual_tile_pos.y) == -1:
		player_tile = actual_tile_pos
	else:
		# If actual tile is obstructed, get the centre pos of the actual tile
		var offset = Vector2.ONE * cell_size / 2
		var centre_pos = map_to_world(actual_tile_pos) + offset
		# Get the direction from the centre of the tile to the player
		var direction = centre_pos.direction_to(player.position)
		# Approximate direction and get the next tile in that direction 
		var next_tile_pos = actual_tile_pos + Utils.approximate_direction_4_ways(direction)
		# Return the next tile pos instead, if unobstructed
		if ceiling.get_cell(next_tile_pos.x, next_tile_pos.y) == -1:
			player_tile = next_tile_pos
	return player_tile

func update_selected_tile():
	var mouse_tile_pos = world_to_map(player.get_global_mouse_position())
	var player_tile_pos = get_player_tile_pos()
	var direction = Utils.approximate_direction_8_ways(player_tile_pos.direction_to(mouse_tile_pos))
	var tile_pos = player_tile_pos + direction
	
	var obstructed = ceiling.get_cell(tile_pos.x, tile_pos.y) != -1
	
	var offset = (Vector2.ONE - direction.normalized()) * cell_size/2
	var closest_point = map_to_world(tile_pos) + offset
	var distance = player.position.distance_to(closest_point)
	
	var out_of_bounds_x = 1 > tile_pos.x or tile_pos.x >= Globals.CAVE_SIZE-1
	var out_of_bounds_y = 1 > tile_pos.y or tile_pos.y >= Globals.CAVE_SIZE-1
	
	if obstructed and distance <= MAX_DISTANCE and not (out_of_bounds_x or out_of_bounds_y):
		select_tile(tile_pos)
	else:
		deselect_tile()

func destroy_selected_tile():
	if not tile_selected: return
	ceiling.destroy_tile(selected_tile, true)
