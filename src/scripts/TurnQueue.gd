extends Node

signal play_turn( combatant )
signal round_over

@export var combatant_container : Node
var round_count : int = 0
var active : bool = true

func execute_actions():
	var combatants = _get_combatants()
	combatants.sort_custom(_sort_by_priority)
	
	for combatant in combatants:
		combatant.queued_action.execute()
		await CombatEvent.hp_updated

func _check_all_inactive(_t, _a):
	if not active: return
	for combatant : Node2D in _get_combatants():
		if combatant.active:
			#print_debug("%s is active!" % combatant.name)
			if combatant.is_in_group(CombatantMonster.PLAYER_GROUP):
				play_turn.emit( combatant )
			return false
	#print_debug("All inactive, executing actions...")
	await execute_actions()
	#print_debug("All actions executed.")
	round_count += 1
	CombatEvent.round_over.emit()
	return true

func _get_combatants()->Array:
	return combatant_container.get_combatants()

func _sort_by_priority(a : CombatantMonster, b : CombatantMonster):
	if a.queued_action.priority == b.queued_action.priority:
		return a.initiative > b.initiative
	return a.queued_action.priority > b.queued_action.priority

func _ready():
	CombatEvent.action_queued.connect(_check_all_inactive)
	CombatEvent.combatant_dead.connect(func(_c): active = false)
	active = true

func clear():
	round_count = 0
	CombatEvent.action_queued.disconnect(_check_all_inactive)
