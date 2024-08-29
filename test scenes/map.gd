extends Node2D

signal encounter_triggered( encounter )

@export var encounter_list : Array[Monster]

@onready var ocean: TileMapLayer = $Ocean
@onready var map: TileMapLayer = $Map
@onready var objects: TileMapLayer = $Objects
@onready var tall_grass: TileMapLayer = $TallGrass
@onready var items : TileMapLayer = $Objects/Items

func _ready():
	var map_data = []
	var map_occupied = map.get_used_cells()

	var objects_data = []
	var objects_occupied = objects.get_used_cells()
	var drop_point_candidates : Array = objects.known_containers.keys()
	#drop_point_candidates.append(Vector2i(14, 5))
	#prints("drop point candidates:", drop_point_candidates)
	drop_item( Vector2(10, 0), ItemManager.get_random_item())

#region MOVEMENT
func is_stepping_on(pos : Vector2):
	var cell_pos = tall_grass.local_to_map(pos)
	if tall_grass.get_cell_tile_data(cell_pos): return "tall_grass"
	cell_pos = map.local_to_map(pos)
	var data = map.get_cell_tile_data(cell_pos).get_custom_data("floor_type")
	return data

func request_move(target_position)->bool:
	var target_cell = map.local_to_map(target_position)
	return _check_map(target_cell) and _check_objects(target_cell)

func _check_objects(target_cell)->bool:
	var occupied_cells = objects.get_used_cells()
	if target_cell in occupied_cells:
		return false
	return true

func _check_map(target_cell)->bool:
	if target_cell:
		var cell_data : TileData = map.get_cell_tile_data(target_cell)
		if not cell_data: return true
		return cell_data.get_custom_data("walkable")
	return true

func check_encounter(target_position):
	return tall_grass.check_encounter(target_position)
#endregion

func check_for_item( target_pos ):
	var target_cell = items.local_to_map( target_pos )
	var data : TileData = items.get_item(target_cell)
	#print(data)

##TODO: Make it so this script only handles requests from the player

#region requests

func drop_item( at : Vector2, item : Item):
	var has_container = objects.get_known_container( at )
	print("has_container: ", has_container)
	if at in has_container.keys():
		print("Item to be dropped in container %s" % str(at))
		var stored = objects.store_in_container(at, item)
		if not stored:
			print("Could not store item")
			return
		print("Item stored")
	else:
		print("Item to be dropped on ground at %s" % str(at))
		items.set_item( at, item )

func loot_items( target_pos : Vector2 ):
	var items = request_items( target_pos )
	return items if items else null

func request_items( target_pos : Vector2 ):
	var tile_pos = items.local_to_map( target_pos )
	print_debug(tile_pos)
	var _container_present = objects.get_known_container( tile_pos )
	var _item_present : Array
	if _container_present is Object:
		_item_present = objects.open_container( tile_pos )
	else:
		_item_present = items.get_items( tile_pos )
		items.remove_item(tile_pos)
	if not _item_present.is_empty():
		return {
			"success" : true,
			"contents" : _item_present if _item_present else []
		}
	return {
		"success" : false,
		"contents" : "No items here to pick up."
	}

func request_examine( target_pos : Vector2 ):
	var tile_pos = objects.local_to_map( target_pos )
	#print("Examining %s" % str(tile_pos))
	var data = objects.get_object_name_at( tile_pos )
	var _item_present = items.get_items( tile_pos )
	#items.get_map()
	#print("Requesting tile: ", tile_pos)
	if data:
		return {
			"success" : true,
			"dialogue" : "It's a %s." % data.replace("_", " "),
			"contents" : _item_present if _item_present else []
		}
	return {
		"success" : false,
		"dialogue" : "Nothing here."
	}

#endregion

# EOF #
