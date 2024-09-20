extends Node

var player_instance : CharacterBody2D : 
	set(v):
		player_instance = v
		SaveManager.load_game( get_id() )
var player_name : StringName = &"Batata"

var world_pos : Vector2
var map_pos : Vector2i

var inventory : Array[Item] = []
var party : Array[Monster]

var rng = RandomNumberGenerator.new()
var id : int

func _ready():
	#id =  rng.randi()
	id = 1234567890
	#print_debug("Player ID: %d\nSecret ID: %d" % [get_id(), get_id(true)])
	
	Event.menu_opened.connect(_on_menu_opened_event)
	Event.menu_closed.connect(_on_menu_closed_event)

#region EVENTS

func _on_menu_opened_event():
	set_player_state(Actor.BUSY)

func _on_menu_closed_event():
	set_player_state(Actor.IDLE)

#endregion

#region PARTY MANAGEMENT
func add_to_party( monster : Monster ):
	if not monster:
		return
	monster.captured_status = Monster.TAMED
	party.push_back( monster )
	print("Added %s to party." % monster.nickname)

func remove_from_party( monster : Monster ): pass

func put_in_position( monster : Monster, idx : int ): pass

func swap_position( a : Monster, b : Monster): pass

func get_party_leader():
	return party.front()
#endregion

#region INVENTORY MANAGEMENT
func add_item( item : Item ):
	if not has_item(item.id):
		inventory.push_back( item )
		return
	get_item(item.id).stack += 1
	return

func get_item(item_id : StringName)->Item:
	return inventory[ find_item(item_id) ]

func remove_item( item_id : StringName)->void:
	var idx = find_item(item_id)
	inventory.remove_at(idx)

func has_item( item_id : StringName )->bool:
	for i : Item in inventory:
		if i.id == item_id:
			return true
	return false

func find_item( item_id : StringName)->int:
	for i in inventory:
		if i.id == item_id:
			return inventory.find(i)
	return -1

func move_item( item_id : StringName, desired_idx : int)->void: 
	if not desired_idx in range(inventory.size()): return
	if inventory[desired_idx]:
		var a = find_item(item_id)
		swap_item_by_index(a, desired_idx)
	else:
		var prev = find_item(item_id)
		var i = inventory[prev]
		inventory.insert(desired_idx, i)
		inventory.remove_at(prev)

func swap_item_by_index(item_idx, desired_idx)->void:
	var a = inventory[item_idx]
	var b = inventory[desired_idx]
	inventory[desired_idx] = a
	inventory[item_idx] = b

#func swap_item( a : Item, b : Item):pass

#endregion

#region PLAYER
func get_player():
	return player_instance if player_instance else null

func get_id( secret : bool = false) -> int:
	var str = str(id).pad_zeros(10)
	if secret: return str.left(4).pad_zeros(4).to_int()
	else: return str.right(6).pad_zeros(6).to_int()

func get_trainer():
	return player_name

func set_player_state( _state ):
	player_instance.state = _state
#endregion

#region SERIALIZATION
func serialize():
	return {
		"id" : [get_id(), get_id(true)], #[0] is visual ID, [1] is secret ID
		"name" : get_trainer(), # StringName
		"global_position" : { 
			"x" : player_instance.global_position.x,
			"y" : player_instance.global_position.y
		},
		"inventory" : _serialize_inventory(),
		"party" : _serialize_party(),
		"flags" : {
		"wokeUpOnShore" : true # example
		}, #flag_id : active (bool)
		"world_time" : roundf(WorldTime.time)
	}

func _serialize_inventory()->Array[Dictionary]:
	var inv_data : Array[Dictionary] = []
	for i : Item in inventory:
		inv_data.push_back( { i.id : i.stack } )
	
	return inv_data

func _serialize_party()->Array[Dictionary]:
	var party_data : Array[Dictionary] = []
	for monster : Monster in party:
		party_data.push_back( monster.serialize() )
	return party_data

func deserialize( data : Dictionary ):
	id = data.id[0]+data.id[1]
	WorldTime.INITIAL_HOUR = data.get("world_time", 0.0)
	player_name = data.name
	var global_pos = Vector2(data.get("global_position", 0).x, data.get("global_position", 0).y)
	player_instance.global_position = global_pos
	inventory = _deserialize_inventory( data.get("inventory", []) )
	party = await _deserialize_party( data.get("party", []) )

func _deserialize_inventory( data : Array )->Array[Item]:
	var inv_data : Array[Item] = []
	for item in data:
		inv_data.push_back( ItemManager.get_item( item.keys()[0], item.values()[0] ) )
	
	return inv_data

func _deserialize_party( party_data : Array )->Array[Monster]:
	var p : Array[Monster] = []
	for member in party_data:
		var monster_id = member.data.species
		var monster = await MonsterManager.generate_tamed_monster(monster_id)
		monster.deserialize( member )
		p.push_back( monster )
	return p
#endregion

# EOF #
