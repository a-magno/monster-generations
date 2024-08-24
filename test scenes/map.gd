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
	prints("drop point candidates:", drop_point_candidates)
	drop_item(drop_point_candidates.pick_random(), ItemManager.get_random_item())

#region MOVEMENT
func is_stepping_on(pos : Vector2):
	var cell_pos = tall_grass.local_to_map(pos)
	if tall_grass.get_cell_tile_data(cell_pos): return "tall_grass"
	cell_pos = map.local_to_map(pos)
	var data = map.get_cell_tile_data(cell_pos).get_custom_data("floor_type")
	return data

func can_move_to(target_position)->bool:
	PlayerData.map_pos = map.local_to_map( target_position )
	return _check_map(target_position) and _check_objects(target_position)

func _check_objects(target_position)->bool:
	var target_cell = objects.local_to_map(target_position)
	var occupied_cells = objects.get_used_cells()
	if target_cell in occupied_cells:
		return false
	
	#if target_cell:
		#var cell_data : TileData = objects.get_cell_tile_data(target_cell)
		#if not cell_data: return true
#
		#return cell_data.get_custom_data("walkable")
	return true

func _check_map(target_position)->bool:
	var target_cell = map.local_to_map(target_position)

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
	if has_container:
		print("Item to be dropped in container %s" % str(at))
		var stored = objects.store_in_container(at, item)
		if not stored:
			print("Could not store item")
		print("Item stored")
	else:
		print("Item to be dropped on ground at %s" % str(at))
		items.set_item( at, item )

func loot_items( target_pos : Vector2 ):
	var items = request_items( target_pos )
	return items if items else null

func request_items( target_pos : Vector2 ):
	var tile_pos = items.local_to_map( target_pos )
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
