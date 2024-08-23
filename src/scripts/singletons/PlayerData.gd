extends Node

var player_instance : CharacterBody2D
var player_name : StringName = &"Batata"

var world_pos : Vector2
var map_pos : Vector2i

var inventory : Array[Item]
var party : Array[Monster]

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
func get_player():
	return player_instance if player_instance else null

# EOF #
