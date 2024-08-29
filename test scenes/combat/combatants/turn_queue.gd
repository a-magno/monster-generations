extends Node

@export var combatants_list : Node2D
var action_queue : Array[CombatAction] : set = _set_action_queue

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
	print_debug("Action queued")
	action_queue.push_back( action )
	play_turn()

func _all_combatants_inactive():
	for combatant in combatants_list.get_combatants():
		if combatant.active:
			print_debug("Not all combatants are done.")
			return false
	print_debug("All combatants are done.")
	return true

func _on_turn_ended(combatant : Combatant):
	combatant.active = false
	if _all_combatants_inactive():
		play_turn()
#
func play_turn():
	for ac in action_queue:
		ac.execute()
	action_queue.clear()
