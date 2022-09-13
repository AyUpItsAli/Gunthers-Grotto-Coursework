extends YSort

# Objects
const STALAGMITE = preload("res://World/Objects/Stalagmite.tscn")
const PLAYER = preload("res://Actors/Player/Player.tscn")
const ROCK_HERMIT = preload("res://Actors/Enemies/RockHermit.tscn")
const GEMSTONE = preload("res://World/Objects/Gemstone.tscn")

# Node references
onready var rock_layer = get_parent().get_node("RockLayer")

# Constants
const CLUSTER_CHANCE = 40 # Chance to spawn each stalagmite in the cluster
const HERMIT_CHANCE = 50 # Chance for a cluster to contain rock hermits instead
const GEMSTONE_CHANCE = 2 # Chance for a rock tile to contain a gemstone

var occupied_tiles = [] # List of tile coordinates occupied by an object
var gemstones = {}

# Converts tile coordinates to a global world position
func tile_pos_to_world_pos(tile_pos: Vector2) -> Vector2:
	var offset = Vector2.ONE * Globals.CAVE_TILE_SIZE/2
	return rock_layer.map_to_world(tile_pos) + offset

# Returns whether the given tile coordinates are occupied by a rock tile
# Used to validate: Objects inside walls
func is_rock(tile_pos: Vector2):
	return rock_layer.get_cell(tile_pos.x, tile_pos.y) == rock_layer.ROCK

# Returns whether the given tile coordinates are unoccupied
# Used to validate: Objects on the ground
func is_unoccupied(tile_pos: Vector2):
	if is_rock(tile_pos): return false
	if tile_pos in occupied_tiles: return false
	return true

func get_random_tile_pos() -> Vector2:
	var random_x = GameManager.rng.randi_range(0, Globals.CAVE_SIZE-1)
	var random_y = GameManager.rng.randi_range(0, Globals.CAVE_SIZE-1)
	return Vector2(random_x, random_y)
 
func get_random_unoccupied_tile_pos() -> Vector2:
	var tile_pos = get_random_tile_pos()
	while not is_unoccupied(tile_pos):
		tile_pos = get_random_tile_pos()
	return tile_pos

# Spawns a stalagmite object at the given tile coordinates
func spawn_stalagmite(tile_pos: Vector2):
	if not is_unoccupied(tile_pos): return
	
	var stalagmite = STALAGMITE.instance()
	stalagmite.position = tile_pos_to_world_pos(tile_pos)
	occupied_tiles.append(tile_pos)
	add_child(stalagmite)

# Spawns a rock hermit enemy at the given tile coordinates
func spawn_rock_hermit(tile_pos: Vector2):
	if not is_unoccupied(tile_pos): return
	
	var rock_hermit = ROCK_HERMIT.instance()
	rock_hermit.position = tile_pos_to_world_pos(tile_pos)
	occupied_tiles.append(tile_pos)
	add_child(rock_hermit)

# Spawns a stalagmite and a cluster of other stalagmites around it
func spawn_stalagmite_cluster():
	var hermit_cluster = GameManager.percent_chance(HERMIT_CHANCE)
	
	var origin_pos = get_random_unoccupied_tile_pos()
	if hermit_cluster: spawn_rock_hermit(origin_pos)
	else: spawn_stalagmite(origin_pos)
	
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var tile_pos = Vector2(origin_pos.x+i, origin_pos.y+j)
				var do_spawn = GameManager.percent_chance(CLUSTER_CHANCE)
				if is_unoccupied(tile_pos) and do_spawn:
					if hermit_cluster: spawn_rock_hermit(tile_pos)
					else: spawn_stalagmite(tile_pos)

# Spawns a number of stalagmite clusters into the world
func spawn_stalagmites():
	for i in range(int(Globals.CAVE_SIZE/2)):
		spawn_stalagmite_cluster()

# Spawns a gemstone object at the given tile coordinates
func spawn_gemstone(tile_pos: Vector2):
	if tile_pos in gemstones: return
	
	var gemstone = GEMSTONE.instance()
	gemstone.position = tile_pos_to_world_pos(tile_pos)
	gemstones[tile_pos] = gemstone
	add_child(gemstone)

# Randomly spawn gemstones for each rock tile in the cave
func spawn_gemstones():
	for x in range(1, Globals.CAVE_SIZE-1):
		for y in range(1, Globals.CAVE_SIZE-1):
			var tile_pos = Vector2(x, y)
			var do_spawn = GameManager.percent_chance(GEMSTONE_CHANCE)
			if is_rock(tile_pos) and do_spawn:
				spawn_gemstone(tile_pos)

func player_exists() -> bool:
	return has_node("Player")

func get_player():
	return get_node("Player")

# Spawns the player node at a random position in the cave
func spawn_player():
	if player_exists():
		remove_child(get_player())
	
	var player = PLAYER.instance()
	var player_pos = get_random_unoccupied_tile_pos()
	player.position = tile_pos_to_world_pos(player_pos)
	occupied_tiles.append(player_pos)
	
	var camera: Camera2D = player.get_camera()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = Globals.CAVE_SIZE * Globals.CAVE_TILE_SIZE
	camera.limit_bottom = Globals.CAVE_SIZE * Globals.CAVE_TILE_SIZE
	
	add_child(player)
