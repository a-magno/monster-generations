extends Node

signal queue_action( data : Dictionary )

@export var combatant : Combatant
@export var list : Node2D
var timer : Timer
const TACKLE = preload("res://src/moves/tackle.tres")

func act(_target : Combatant):
	var target = _target
	if not timer.is_inside_tree(): return
	if not timer.is_stopped(): return
	if not combatant.active:return
	timer.start()
	
	await target.turn_done
	print("AI attacking...")
	CombatHandler.action_queued.emit(
		CombatAction.new(
			combatant, CombatAction.Actions.FIGHT,
			target, TACKLE
		)
	)
	await timer.timeout
	combatant.active = false

## Chooses between FIGHT or ITEM
func _evaluate_actions():pass
func _evaluate_item():pass
func _choose_move():pass
