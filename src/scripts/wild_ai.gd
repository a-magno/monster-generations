extends Node

signal queue_action( data : Dictionary )

@export var combatant : CombatantMonster
@export var list : Node2D
var timer : Timer
const TACKLE = preload("res://src/moves/tackle.tres")

func _process(delta):
	if not combatant.active:
		return
	act( get_tree().get_first_node_in_group( CombatantMonster.PLAYER_GROUP ) )

func act(_target : CombatantMonster):
	var target = _target
	#if not timer.is_inside_tree(): return
	#if not timer.is_stopped(): return
	if not combatant.active:return
	#timer.start()
	combatant.fight( target, TACKLE )
	#CombatEvent.ui_move_selected.emit(TACKLE, combatant, target)
	#await timer.timeout
	combatant.active = false

## Chooses between FIGHT or ITEM
#func _evaluate_actions():pass
#func _evaluate_item():pass
#func _choose_move():pass
