tool
extends TileSet

# Override _is_tile_bound() so that ALL auto-tiles in the tileset bind to each other
func _is_tile_bound(drawn_id, neighbor_id):
	return neighbor_id in get_tiles_ids()
