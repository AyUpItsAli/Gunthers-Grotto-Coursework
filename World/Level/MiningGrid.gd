extends TileMap

const SELECTED = 0
const MAX_DISTANCE = 36

onready var walls = get_parent().get_node("Walls")
onready var objects = get_parent().get_node("Objects")
onready var ceiling = get_parent().get_node("Ceiling")

var player: Player
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

func update_selected_tile():
	var player_tile_pos = world_to_map(player.position)
	var tile_pos = player_tile_pos + player.facing
	
	var offset = Vector2.ONE * ceiling.cell_size / 2
	var centre = ceiling.map_to_world(tile_pos) + offset
	if player.position.distance_to(centre) > MAX_DISTANCE:
		tile_pos = player_tile_pos
	
	var obstructed = ceiling.get_cell(tile_pos.x, tile_pos.y) != -1
	var out_of_bounds_x = 1 > tile_pos.x or tile_pos.x >= Globals.CAVE_SIZE-1
	var out_of_bounds_y = 1 > tile_pos.y or tile_pos.y >= Globals.CAVE_SIZE-1
	
	if obstructed and not (out_of_bounds_x or out_of_bounds_y):
		select_tile(tile_pos)
	else:
		deselect_tile()

func destroy_selected_tile():
	if not tile_selected: return
	ceiling.destroy_tile(selected_tile, true)
