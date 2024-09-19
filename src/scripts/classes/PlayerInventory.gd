extends ContainerCore

signal item_added
signal item_removed

## Initializes with an id and size, connects to Event.item_collected and
## Event.drop_item, and returns itself (for PlayerData initialization purposes)
func _init(_id, _inv_size):
	id = _id
	size = _inv_size
	#Event.item_collected.connect(add_item)
	#Event.item_drop.connect(remove_item)

func add_item( item ):
	if has_item( item ):
		_items[item.id].stack += item.stack
	else:
		_items.merge( { item.id : item } )
	item_added.emit()

func remove_item( item_id ):
	_items.erase(item_id)
	item_removed.emit()
	return _items.has(item_id)

## Returns inventory.values()
func get_items()->Array:
	return _items.values()

## Returns the entire inventory dictionary
func _get_inventory() -> Dictionary:
	return _items

## Returns an array of dictionaries in the {item_id : stack} format
func serialize()->Dictionary:
	var data = {}
	for i : Item in get_items():
		data.merge( { i.id : i.stack } )
	return data

## Populates inventory with items by calling ItemLibrary.get_item(id) on every
## element of the data array
func deserialize( data : Dictionary ) -> void:
	var items = {}
	for k in data.keys():
		var i : Item = ItemManager.items.get(k)
		i.stack = data[k]
		items.append( i )
	_items = items
