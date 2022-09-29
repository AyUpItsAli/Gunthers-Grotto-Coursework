extends Node2D

const ITEM_DISPLAY = preload("res://GUI/HUD/ItemDisplay.tscn")

# A reference to the UI node, in order to invoke "rearrange_item_displays()"
onready var ui = get_parent()

func _ready():
	PlayerData.connect("inventory_changed", self ,"update_inventory_display")

func update_inventory_display():
	# Clear the current item displays
	for item_display in get_children():
		remove_child(item_display)
	
	# Add an item display for each item in the inventory
	for item_id in PlayerData.inventory:
		var item_display: Node2D = ITEM_DISPLAY.instance()
		var image = Globals.ITEMS[item_id].texture
		item_display.get_node("Image").texture = image
		var amount = PlayerData.inventory[item_id]
		item_display.get_node("Label").text = str(amount)
		add_child(item_display)
	
	# Rearrange the item displays to fit within the inventory display
	ui.rearrange_item_displays()
