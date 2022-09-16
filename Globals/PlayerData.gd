extends Node

var health = 5
var inventory = {} # key: Item ID | value: Quantity

func reduce_health(amount: int):
	health -= amount
	if health <= 0:
		health = 0
		print("Game Over")

# Attempts to ADD an item to the inventory
# Returns whether the item was able to be added or not
func add_item(item_id: int, amount: int = 1) -> bool:
	if not item_id in Globals.ITEMS: return false
	if item_id in inventory:
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	return true

# Attempts to REMOVE an item from the inventory
# Returns whether the item was able to be removed or not
func remove_item(item_id: int, amount: int = 1) -> bool:
	if not item_id in Globals.ITEMS: return false
	if not item_id in inventory: return false
	var current_quantity: int = inventory[item_id]
	if amount > current_quantity:
		return false
	elif amount == current_quantity:
		inventory.erase(item_id)
		return true
	else:
		inventory[item_id] -= amount
		return true
