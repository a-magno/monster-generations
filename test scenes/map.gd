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
	#for cell in map_occupied:
		#var tile_volume = items.get_tile_volume( cell )
		#items.set_cell(cell, 0, Vector2i(9, 8))
		#items.get_cell_tile_data( cell ).set_custom_data("items", [])
		#if items.get_tile_volume(cell) <= 0.0:
			#items.set_tile_volume(cell, tile_volume)
		#print("%s volume is %f" % [cell, items.get_tile_volume(cell)])

	var objects_data = []
	var objects_occupied = objects.get_used_cells()
	var known_containers = objects.get_known_containers()
	
	prints("Known containers:", known_containers)
	items.set_item( known_containers.pick_random(), ItemManager.get_random_item() )
	items.set_item( known_containers.pick_random(), ItemManager.get_random_item() )
	items.set_item( Vector2i(14, 5), ItemManager.get_random_item() )

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

	if target_cell:
		var cell_data : TileData = objects.get_cell_tile_data(target_cell)
		if not cell_data: return true

		return cell_data.get_custom_data("walkable")
	return true

func _check_map(target_position)->bool:
	var target_cell = map.local_to_map(target_position)

	if target_cell:
		var cell_data : TileData = map.get_cell_tile_data(target_cell)
		if not cell_data: return true

		return cell_data.get_custom_data("walkable")
	return true

func check_encounter(target_position):
	var target_cell = tall_grass.local_to_map(target_position)
	var cell_data = tall_grass.get_cell_tile_data(target_cell)

	if not cell_data: return null
	
	var chance = cell_data.get_custom_data("encounter_rate")
	if cell_data.get_custom_data("encounter_rate"):
		
		#encounter_triggered.emit( target_cell )
		if _roll_encounter(chance):
			var wild_one : Monster = MonsterManager.generate_random_wild_monster()
			encounter_triggered.emit( wild_one )
	
func _roll_encounter(encounter_chance):
	randomize()
	return randf_range(0, 1) > encounter_chance

func check_for_item( target_pos ):
	var target_cell = items.local_to_map( target_pos )
	var data : TileData = items.get_item(target_cell)
	#print(data)

##TODO: Make it so this script only handles requests from the player

#region requests

func loot_items( target_pos : Vector2 ):
	var items = request_items( target_pos )
	return items if items else null

func request_items( target_pos : Vector2 ):
	var tile_pos = items.local_to_map( target_pos )
	var _item_present = items.get_items( tile_pos )
	items.remove_item(tile_pos)
	objects.open_container(tile_pos)
	if _item_present:
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
