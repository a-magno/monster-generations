extends Node

signal active_changed( active_combatant : Combatant )

@export var combatants_list : Node2D
var queue = []: set = _set_queue
var active_combatant : Combatant = null : set = _set_active_combatant

func start():
	_set_queue( combatants_list.get_combatants() )
	play_turn()

func play_turn():
	#await get_parent().get_node("Battle UI").update_over
	if not active_combatant.active:
		return
	await active_combatant.turn_done
	get_next_in_queue()
	play_turn()

func get_next_in_queue():
	var current_combatant = queue.pop_front()
	current_combatant.active = false
	queue.append(current_combatant)
	active_combatant = queue.front()
	return active_combatant
	
func remove(combatant):
	var new_queue = []
	for n in queue:
		new_queue.append(n)
	new_queue.remove(new_queue.find(combatant))
	combatant.queue_free()
	queue = new_queue


func _set_queue(new_queue):
	queue.clear()
	for node in new_queue:
		queue.append(node)
		node.active = false
		queue.sort_custom(_sort_by_speed)
	if queue.size() > 0:
		active_combatant = queue.front()

func _sort_by_speed(a : Combatant, b : Combatant):
	return a.initiative > b.initiative

func _set_active_combatant(new_combatant):
	active_combatant = new_combatant
	active_combatant.active = true
	active_changed.emit(active_combatant)
