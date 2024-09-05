extends Node

signal play_turn( combatant )
signal round_over

@export var combatant_container : Node

func execute_actions():
	var combatants = _get_combatants()
	combatants.sort_custom(_sort_by_priority)
	
	for combatant in combatants:
		combatant.queued_action.execute()
		combatant.active = false

func _check_all_inactive():
	for combatant : Node2D in _get_combatants():
		if combatant.active:
			if combatant.is_in_group(CombatHandler.PLAYER_GROUP):
				play_turn.emit( combatant )
			return false
	await execute_actions()
	round_over.emit()
	return true

func _get_combatants()->Array:
	return combatant_container.get_combatants()

func _sort_by_priority(a : CombatantMonster, b : CombatantMonster):
	if a.queued_action.priority == b.queued_action.priority:
		return a.initiative > b.initiative
	return a.queued_action.priority > b.queued_action.priority
