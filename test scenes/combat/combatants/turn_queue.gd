extends Node


var action_queue : Array[CombatAction] : set = _set_action_queue

signal active_changed( active_combatant : Combatant )

@export var combatants_list : Node2D
var queue = []: set = _set_queue
var active_combatant : Combatant = null : set = _set_active_combatant

func _ready():
	CombatHandler.action_queued.connect(_action_queued)

func _sort_by_priority(a : CombatAction, b : CombatAction):
	return a.priority > b.priority

func _set_action_queue( new_queue ):
	action_queue.clear()
	for action in new_queue:
		action_queue.append(action_queue)
		action_queue.sort_custom(_sort_by_priority)

func _action_queued( action : CombatAction ):
	action_queue.push_back( action )
	print(action_queue)

func _all_combatants_inactive():
	for combatant in combatants_list.get_combatants():
		if combatant.active:
			return false
	return true

func start():
	_set_queue( combatants_list.get_combatants() )
	play_turn()
##
func play_turn():
	#await get_parent().get_node("Battle UI").update_over
	if not _all_combatants_inactive():
		return
	active_combatant = await CombatHandler.turn_ended
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
