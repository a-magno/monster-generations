extends RefCounted
class_name ContainerCore

var id : StringName # For lookup purposes in InventoryHandler singleton
var size : int # Defines the maximum amount of items the player can hold
var _items : Dictionary = {} # Stored as item_id : item (Item resource)

## Adds an item to the inventory array. Returns true if an item was added, false it somehow failed.
## The key param is left as a Variant so that anything can be used as a key depending on what is inherited.
func add_item( item ): pass

## Removes an item from the inventory. Returns true if an item was removed, false it somehow failed.
func remove_item( item_id : StringName ): pass

## Checks if the inventory has a given item
func has_item( item : Item ) -> bool:
	return _items.values().has(item)

## Gets a particular item from the inventory.
func get_item( item_id : StringName ) -> bool:
	return _items.get(item_id, null)

## Returns the index of a given item_id
func find_item (item_id : StringName = "*" ) -> int:
	return _items.find_key(item_id)
