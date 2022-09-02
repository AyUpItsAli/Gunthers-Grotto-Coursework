extends YSort

# Objects
const STALAGMITE = preload("res://World/Objects/Stalagmite.tscn")

# Node references
onready var rock_layer = get_parent().get_node("RockLayer")

# Constants
const CLUSTER_CHANCE = 40 # Chance to spawn each stalagmite in the cluster

var occupied_tiles = [] # List of tile coordinates occupied by an object

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

# Spawns a stalagmite and a cluster of other stalagmites around it
func spawn_stalagmite_cluster():
	var origin_pos = get_random_unoccupied_tile_pos()
	spawn_stalagmite(origin_pos)
	
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			if not (i == 0 and j == 0):
				var tile_pos = Vector2(origin_pos.x+i, origin_pos.y+j)
				var do_spawn = GameManager.percent_chance(CLUSTER_CHANCE)
				if is_unoccupied(tile_pos) and do_spawn:
					spawn_stalagmite(tile_pos)

# Spawns a number of stalagmite clusters into the world
func spawn_stalagmites():
	for i in range(int(Globals.CAVE_SIZE/2)):
		spawn_stalagmite_cluster()
