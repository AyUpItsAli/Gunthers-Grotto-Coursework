extends YSort

# Objects
const STALAGMITE = preload("res://World/Objects/Stalagmite.tscn")
const PLAYER = preload("res://Actors/Player/Player.tscn")
const ROCK_HERMIT = preload("res://Actors/Enemies/RockHermit.tscn")
const GEMSTONE = preload("res://World/Objects/Gemstone.tscn")
const CAVE_EXIT = preload("res://World/Objects/CaveExit.tscn")

# Node references
onready var level = get_parent().get_parent() # Root node of the Level scene
onready var walls = get_parent().get_node("Walls")

# Constants
const CLUSTER_CHANCE = 40 # Chance to spawn each stalagmite in the cluster
const HERMIT_CHANCE = 50 # Chance for a cluster to contain rock hermits instead
const GEMSTONE_CHANCE = 2 # Chance for a wall tile to contain a gemstone

var occupied_tiles = [] # List of tile coordinates occupied by an object
var gemstones = {} # Dict of tile coordinates and their corresponding gemstones

# Completely removes all objects present in the level
func clear_objects():
	# Remove all objects
	for child in get_children():
		remove_child(child)
	# Clear object lists
	occupied_tiles = []
	gemstones = {}

# Converts tile coordinates to a global world position
func tile_pos_to_world_pos(tile_pos: Vector2) -> Vector2:
	var offset = Vector2.ONE * Globals.CAVE_TILE_SIZE/2
	return walls.map_to_world(tile_pos) + offset

# Returns whether the given tile coordinates are occupied by a wall tile
# Used to validate: Objects inside walls
func is_wall(tile_pos: Vector2):
	return walls.get_cellv(tile_pos) == walls.WALL

# Returns whether the given tile coordinates are unoccupied
# Used to validate: Objects on the ground
func is_unoccupied(tile_pos: Vector2):
	if is_wall(tile_pos) or is_wall(tile_pos + Vector2.UP): return false
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
	
	for i in range(-1, 2):
		for j in range(-1, 2):
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

# Randomly spawns gemstones for each wall tile in the cave
func spawn_gemstones():
	for x in range(1, Globals.CAVE_SIZE-1):
		for y in range(1, Globals.CAVE_SIZE-1):
			var tile_pos = Vector2(x, y)
			if is_wall(tile_pos):
				if GameManager.percent_chance(GEMSTONE_CHANCE):
					spawn_gemstone(tile_pos)

func player_exists() -> bool:
	return has_node("Player")

func get_player() -> Player:
	return get_node("Player") as Player

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

# Returns whether the given tile pos is a valid spawning location for the cave exit.
# Tiles to the left and right should also be unoccupied, as the cave exit is a large object
func is_valid_cave_exit_pos(tile_pos: Vector2) -> bool:
	return (is_unoccupied(tile_pos) and
			is_unoccupied(tile_pos + Vector2.LEFT) and
			is_unoccupied(tile_pos + Vector2.RIGHT))

# Returns a random tile position that is valid for spawning the cave exit
func get_random_cave_exit_pos(player_pos: Vector2) -> Vector2:
	var furthest_valid_tile: Vector2
	var furthest_distance: float
	var valid_tiles = [] # List of tiles that are far enough away from the player
	
	var rect = walls.get_used_rect()
	for x in range(rect.position.x, rect.position.x+rect.size.x):
		for y in range(rect.position.y, rect.position.y+rect.size.y):
			var tile_pos = Vector2(x, y)
			if not is_valid_cave_exit_pos(tile_pos): # Tile must be valid
				continue
			var distance = player_pos.distance_to(tile_pos)
			if distance > furthest_distance:
				furthest_valid_tile = tile_pos
				furthest_distance = distance
			# Idealy, the tile must be at least half the width of the map away
			# If no tiles meet this criteria, the furthest tile will be picked (see below)
			if distance >= Globals.CAVE_SIZE/2:
				valid_tiles.append(tile_pos)
	# If there ARE tiles far enough away, pick a random one...
	if valid_tiles:
		return GameManager.choose_from(valid_tiles)
	else: # ...otherwise pick the furthest tile possible
		return furthest_valid_tile

# Spawns the cave exit at a random position, a certain distance from the player
func spawn_cave_exit():
	if not player_exists():
		return
	var cave_exit = CAVE_EXIT.instance()
	var player_pos = walls.world_to_map(get_player().position)
	var cave_exit_pos = get_random_cave_exit_pos(player_pos)
	cave_exit.position = tile_pos_to_world_pos(cave_exit_pos)
	for x in range(-1, 2):
		for y in range(-1, 2):
			var offset = Vector2(x, y)
			occupied_tiles.append(cave_exit_pos + offset)
	cave_exit.connect("player_entered", level, "on_player_exited_cave")
	add_child(cave_exit)

# Called by the walls tilemap when a wall tile is destroyed.
# Destroys the gemstone at this tile position, if one is present.
# Adds a random number of gems, taken from gem_quantity_pool, to the inventory.
func destroy_gemstone_if_present(tile_pos: Vector2):
	if tile_pos in gemstones:
		var gemstone: Node2D = gemstones[tile_pos]
		var gem_quantity = GameManager.random_pool_entry(
			GameManager.gem_quantity_pool)
		PlayerData.add_item(Globals.ItemIDs.GEM, gem_quantity)
		gemstone.queue_free()
