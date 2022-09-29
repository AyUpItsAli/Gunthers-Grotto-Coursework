extends Node2D

# Node references
onready var minimap = $Minimap
onready var health_bar = $HealthBar
onready var health_bar_sprite = $HealthBar/BaseSprite
onready var debug_inv_line = $DebugInvLine

# Space between UI elements. Scales with the size of the viewport.
const PADDING = 2
# Maximum percentage of the viewport's WIDTH that the minimap can occupy
const MINIMAP_MAX_WIDTH_PERCENTAGE = 25
# Maximum percentage of the viewport's HEIGHT that the minimap can occupy
const MINIMAP_MAX_HEIGHT_PERCENTAGE = 25
# Maximum percentage of the viewport's WIDTH that the health bar can occupy
const HEALTH_BAR_MAX_WIDTH_PERCENTAGE = 25
# Maximum percentage of the viewport's HEIGHT that the health bar can occupy
const HEALTH_BAR_MAX_HEIGHT_PERCENTAGE = 7.5
# Inventory display's height will be the health bar's height,
# multiplied by this number. For example, 2x the health bar's height
const INVENTORY_HEALTH_BAR_HEIGHT_RATIO = 1.75

# Viewport dimensions
var viewport_width: float
var viewport_height: float

# Health bar dimensions
var hb_width: float
var hb_height: float

# Inventory dimensions
var inv_start_x: float
var inv_start_y: float
var inv_width: float
var inv_height: float

# Padding size
var padding: float

func _ready():
	get_viewport().connect("size_changed", self, "update_ui")
	update_ui()

# Sets the dimensions and position for each UI element,
# to fit on the screen correctly
func update_ui():
	viewport_width = get_viewport_rect().size.x
	viewport_height = get_viewport_rect().size.y
	padding = viewport_width * (PADDING / 100.0)
	set_minimap_dimensions()
	set_health_bar_dimensions()
	set_inventory_display_dimensions()
	center_inventory_and_health_bar()
	draw_inventory_display_bounding_box()

# Sets the minimap's dimensions, based on the size of the viewport
func set_minimap_dimensions():
	# Determine the maximum dimensions
	var max_width = viewport_width * (MINIMAP_MAX_WIDTH_PERCENTAGE / 100.0)
	var max_height = viewport_height * (MINIMAP_MAX_HEIGHT_PERCENTAGE / 100.0)
	# Calculate local size
	# I can use either cell_size.x or cell_size.y, as the minimap is square
	var local_size = Globals.CAVE_SIZE * minimap.cell_size.x
	# Pick the smallest scale, as to not exceed the max_width or max_height
	var map_scale = min(max_width, max_height) / local_size
	# Set the scale
	minimap.scale.x = map_scale
	minimap.scale.y = map_scale
	# Set the position of the minimap to the top right,
	# with padding applied
	var minimap_size = local_size * map_scale
	minimap.position.x = viewport_width - minimap_size - padding
	minimap.position.y = padding

# Sets the health bar's dimensions, based on the size of the viewport
func set_health_bar_dimensions():
	# Determine maximum dimensions
	var max_width = viewport_width * (HEALTH_BAR_MAX_WIDTH_PERCENTAGE / 100.0)
	var max_height = viewport_height * (HEALTH_BAR_MAX_HEIGHT_PERCENTAGE / 100.0)
	# Store local dimensions
	var local_width = health_bar_sprite.texture.get_width()
	var local_height = health_bar_sprite.texture.get_height()
	# Determine maximum scales
	var max_x_scale = max_width / local_width
	var max_y_scale = max_height / local_height
	# Pick the smallest scale, as to not exceed either of them
	var hb_scale = min(max_x_scale, max_y_scale) # Pick the smallest scale
	# Set the scale
	health_bar.scale.x = hb_scale
	health_bar.scale.y = hb_scale
	# Set global variables
	hb_width = local_width * hb_scale
	hb_height = local_height * hb_scale
	# Set the position of the health bar to the bottom left,
	# with padding applied
	health_bar.position.x = padding
	health_bar.position.y = viewport_height - padding

# Sets the inventory display's dimensions, based on the size of the viewport
# and the dimensions of the health bar
func set_inventory_display_dimensions():
	# Set the position of the inventory display to the right of the health bar
	inv_start_x = health_bar.position.x + hb_width + padding
	inv_start_y = viewport_height - padding
	# Set the width, so that the inventory display is symmetrical
	inv_width = ((viewport_width / 2) - inv_start_x) * 2
	# Set the height to
	inv_height = hb_height * INVENTORY_HEALTH_BAR_HEIGHT_RATIO

# Centers the health bar against the inventory display in the Y axis
func center_inventory_and_health_bar():
	health_bar.position.y = inv_start_y - (abs(hb_height - inv_height) / 2)

# Adds points to the DebugLine at each corner of the inventory display,
# to visually see the extents of the inventory display
func draw_inventory_display_bounding_box():
	var points = []
	var inv_end_x = inv_start_x + inv_width
	var inv_end_y = inv_start_y - inv_height
	points.append(Vector2(inv_start_x, inv_start_y))
	points.append(Vector2(inv_start_x, inv_end_y))
	points.append(Vector2(inv_end_x, inv_end_y))
	points.append(Vector2(inv_end_x, inv_start_y))
	# Add the starting point again, to close the shape
	points.append(Vector2(inv_start_x, inv_start_y))
	debug_inv_line.points = points
