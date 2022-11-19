extends Node

# Product details
const PRODUCT_VERSION = "1.0.3-alpha"

# Cave Generation
const CAVE_SIZE = 50 # number of tiles
const CAVE_TILE_SIZE = 32 # number of pixels

# Tile IDs
const GROUND = 0
const WALL = 0
const WALL_DAMAGED_1 = 1
const CEILING = 0
const CEILING_DAMAGED_1 = 1
# Each tile family specifies both a list of ceiling variants and a list wall variants.
# The lists should be ordered from "least damaged variant" to "most damaged variant".
const TILE_FAMILIES = {
	0: {
		ceiling = [CEILING, CEILING_DAMAGED_1],
		walls = [WALL, WALL_DAMAGED_1]
	}
}

# Items
enum ItemIDs { GEM, REVOLVER_AMMO, DYNAMITE_STICK }
const ITEMS = {
	ItemIDs.GEM: {
		single = "Gem",
		plural = "Gems",
		texture = preload("res://Assets/GUI/Items/Gem.png")
	},
	ItemIDs.REVOLVER_AMMO: {
		single = "Bullet",
		plural = "Bullets",
		texture = preload("res://Assets/GUI/Items/Bullet.png")
	},
	ItemIDs.DYNAMITE_STICK: {
		single = "Dynamite Stick",
		plural = "Dynamite Sticks",
		texture = preload("res://Assets/GUI/Items/Dynamite.png")
	}
}
# Frequencies for each quantity of gems you can recieve from mining gemstones
const GEM_FREQUENCIES = { 1: 50, 2: 35, 3: 15 }
# Frequencies for each quantity of bullets rewarded by the magpie
const BULLET_REWARD_FREQUENCIES = { 1: 50, 2: 30, 3: 10, 4: 5, 5: 3, 6: 2}
# Frequencies for each quantity of dynamite rewarded by the magpie
const DYNAMITE_REWARD_FREQUENCIES = { 0: 75, 1: 15, 2: 8, 3: 2}
