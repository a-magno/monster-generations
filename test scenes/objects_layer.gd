extends TileMapLayer

var known_containers : Dictionary = {}

func get_known_containers():
	var occupied = get_used_cells()
	var containers = []
	for cell in occupied:
		var data = get_cell_tile_data( cell )
		var is_container = data.get_custom_data( "container" )
		if is_container:
			containers.append( cell )
	
	return containers

#TODO: get_container(pos), store_in_container(pos, item), open_container(pos)
func open_container( pos : Vector2i):
	if get_object_name_at(pos).containsn("chest"):
		var atlas = get_cell_atlas_coords( pos )
		atlas.x += 1
		set_cell(pos, 3, atlas)

func get_object_name_at( pos ):
	var data = get_cell_tile_data( pos )
	if not data:
		return null
	return data.get_custom_data( "object_name" )
