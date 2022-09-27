extends Node2D

# Node references
onready var minimap = $Minimap
onready var health_bar = $HealthBar
onready var health_bar_sprite = $HealthBar/BaseSprite

# Space between UI elements. Scales with the size of the viewport.
const PADDING = 10
# Maximum percentage of the viewport's WIDTH that the minimap can occupy
const MINIMAP_MAX_WIDTH_PERCENTAGE = 20
# Maximum percentage of the viewport's HEIGHT that the minimap can occupy
const MINIMAP_MAX_HEIGHT_PERCENTAGE = 20
# Maximum percentage of the viewport's WIDTH that the health bar can occupy
const HEALTH_BAR_MAX_WIDTH_PERCENTAGE = 25
# Maximum percentage of the viewport's HEIGHT that the health bar can occupy
const HEALTH_BAR_MAX_HEIGHT_PERCENTAGE = 25

# Viewport dimensions
var viewport_width: float
var viewport_height: float

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
	# Set the position of the health bar to the bottom left,
	# with padding applied
	health_bar.position.x = padding
	health_bar.position.y = viewport_height - padding
