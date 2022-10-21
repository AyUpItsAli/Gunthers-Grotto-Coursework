extends Node

const MAX_HEALTH = 10

onready var starting_inventory = {
	Globals.ItemIDs.REVOLVER_AMMO: 24,
	Globals.ItemIDs.DYNAMITE_STICK: 2
}

var health = MAX_HEALTH
var inventory = {} # key: Item ID | value: Quantity

signal health_changed
signal inventory_changed

func reset_player_data():
	health = MAX_HEALTH
	inventory = starting_inventory

func reduce_health(amount: int):
	health -= amount
	if health < 0:
		health = 0
	emit_signal("health_changed")
	if health == 0:
		print("Game Over")

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
