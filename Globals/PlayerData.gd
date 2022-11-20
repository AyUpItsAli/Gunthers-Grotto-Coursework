extends Node

enum Tools { PICKAXE, REVOLVER, DYNAMITE }
const MAX_HEALTH = 10
const STARTING_INVENTORY = {
	Globals.ItemIDs.REVOLVER_AMMO: 24,
	Globals.ItemIDs.DYNAMITE_STICK: 2
}

var equipped_tool: int
var health: int
var inventory: Dictionary

signal equipment_changed
signal health_changed
signal inventory_changed

func reset_player_data():
	equipped_tool = Tools.PICKAXE
	health = MAX_HEALTH
	inventory = STARTING_INVENTORY.duplicate()
	emit_signal("equipment_changed")
	emit_signal("health_changed")
	emit_signal("inventory_changed")

func equip(new_tool: int):
	equipped_tool = new_tool
	emit_signal("equipment_changed")

func reduce_health(amount: int) -> bool:
	health -= amount
	if health < 0:
		health = 0
	emit_signal("health_changed")
	return health > 0 # Return whether the player survived

# Attempts to ADD an item to the inventory
# Returns whether the item was able to be added or not
func add_item(item_id: int, amount: int = 1) -> bool:
	if not item_id in Globals.ITEMS: return false
	if amount < 0: return false
	if amount == 0: return true
	if item_id in inventory:
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	emit_signal("inventory_changed")
	return true

# Attempts to REMOVE an item from the inventory
# Returns whether the item was able to be removed or not
func remove_item(item_id: int, amount: int = 1) -> bool:
	if not item_id in Globals.ITEMS: return false
	if not item_id in inventory: return false
	if amount < 0: return false
	if amount == 0: return true
	var current_quantity: int = inventory[item_id]
	if amount > current_quantity:
		return false
	elif amount == current_quantity:
		inventory.erase(item_id)
		emit_signal("inventory_changed")
		return true
	else:
		inventory[item_id] -= amount
		emit_signal("inventory_changed")
		return true
