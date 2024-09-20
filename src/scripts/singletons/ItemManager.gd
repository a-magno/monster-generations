extends Node

# Dictionary to store loaded item resources
var items : Dictionary = {}

# Path to the folder containing item resources
const item_folder : String = "res://src/items/"

# Called when the node is added to the scene for the first time
func _ready():
	load_all_items()

# Loads all item resources from the specified folder
func load_all_items() -> void:
	var dir = DirAccess.open(item_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var item_path = item_folder + file_name
				var item_resource = load(item_path)
				if item_resource and item_resource is Item:
					items[item_resource.id] = item_resource
					print("Loaded item: %s" % item_resource.id)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error: Unable to open item folder: %s" % item_folder)

# Unloads a specific item by ID
func unload_item(item_id : StringName) -> void:
	if item_id in items:
		items.erase(item_id)
		print("Unloaded item: %s" % item_id)
	else:
		print("Error: Monster with ID '%s' not found." % item_id)

# Unloads all items to free up resources
func unload_all_items() -> void:
	items.clear()
	print("Unloaded all items")

func get_random_item()->Item:
	var item = items.values().pick_random()
	return item.duplicate()

func get_item( id : StringName, amount : int = 1) -> Item:
	for item : Item in items.values():
		if item.id == id:
			var i : Item = item.duplicate()
			i.stack = amount
			return i
	return null
