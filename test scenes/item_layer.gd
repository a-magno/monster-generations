extends TileMapLayer

@export var default_container_volume : float = 0.0
@export var ground : TileMapLayer

var items_present : Dictionary = {}

func get_items( pos : Vector2i )->Array:
	print("Getting items at %s" % str(pos))
	var res = items_present.get(pos, [])
	if res.size() <= 0:
		print("No items at %s" % str(pos))
		return []
	return res

#region handle items
func set_item( pos : Vector2i, item : Item ):
	var items = items_present.get(pos, [])
	var stack = {}
	if items.size() <= 0:
		items = [item]
	else:
		items.push_back(item)
	
	for i in items:
		print(i.id)
	stack = {pos : items}
	items_present.merge( stack )
	set_cell( pos, 0, Vector2(9, 8) )
	for s in items_present:
		print(JSON.stringify(stack))
	#print("Item [%s] set at %s" % [item.id, str(pos)])

func get_item( pos : Vector2i )->Item:
	var items = items_present.get(pos, null)
	return items.first() if items else null

func remove_item( pos : Vector2i):
	items_present.erase(pos)

func drop_item( pos : Vector2i, item : Item):
	var present_items = []
	
	#if items: present_items.append_array(items)
	
	if get_tile_volume( pos ) <= 0.0:
		print("Insufficient volume at %s" % str(pos))
		return false
	var data : TileData = get_cell_tile_data( pos )
	
	present_items.append(item.id)
	data.set_custom_data( "items", present_items )
	print("present items size: ", present_items.size())
	print("%s dropped at %s" % [ item.id, str(pos) ])
	return true
#endregion

func get_tile_volume( pos : Vector2i ):
	var data = get_cell_tile_data( pos )
	if not data:
		data = ground.get_cell_tile_data( pos )
	var max_volume = data.get_custom_data( "max_volume" )
	if not max_volume:
		return 0.0
	return max_volume

func set_tile_volume(pos : Vector2i, vol = default_container_volume):
	var data = get_cell_tile_data(pos)
	data.set_custom_data( "max_volume", vol )

func get_map():
	var cells = get_used_cells()
	for c in cells:
		var i = get_cell_tile_data(c).get_custom_data("items")
		print("is array? ", i is Array)
		#print("is item? ", i is Item)
		if i is Array:
			for e in i:
				print("is an item? ", e is Item)
		print(i)
