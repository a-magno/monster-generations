extends TileMapLayer

class ItemStorage extends RefCounted:
	var pos_in_grid : Vector2i
	var max_capacity : int
	var capacity : int
	var inventory : Array[Item]
	var atlas := {
		&"open" : Vector2i.RIGHT,
		&"close" : Vector2i.ZERO
	}
	func _init(_pos, _max_cap, atlas_coords):
		pos_in_grid = _pos
		capacity = _max_cap
		atlas[&"close"] = atlas_coords
		atlas[&"open"] += atlas_coords
	
	func store_item( item : Item ):
		if (
			(not inventory.has(item) or inventory[inventory.find(item)].stack+1 < item.max_stack)
			and capacity < max_capacity
			):
			inventory.push_back( item )
			return
		inventory[inventory.find(item)].stack += 1
	
	func inspect():
		return {
			"capacity" : capacity,
			"max_capacity" : max_capacity,
			"inventory" : inventory,
			"position" : pos_in_grid
		}
	
	func get_inventory():
		return inventory

var known_containers : Dictionary = {}

func get_known_containers():
	var occupied = get_used_cells()
	#var containers = []
	for cell in occupied:
		var data = get_cell_tile_data( cell )
		var is_container = data.get_custom_data( &"container" )
		if is_container:
			var storage_limit = data.get_custom_data( &"storage_limit" )
			var atlas = get_cell_atlas_coords( cell )
			var c = ItemStorage.new(cell, storage_limit, atlas)
			known_containers.merge( { cell : c } )
	
	return known_containers

#TODO: get_container(pos), store_in_container(pos, item), open_container(pos)
func open_container( pos : Vector2i ):
	var c : ItemStorage = known_containers.get(pos, null)
	if c:
		print("Opening container...")
		set_cell(pos, 3, c.atlas[&"open"])
		return c.get_inventory()

func get_object_name_at( pos ):
	var data = get_cell_tile_data( pos )
	if not data:
		return null
	return data.get_custom_data( "object_name" )
