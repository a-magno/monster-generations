extends Node

signal queue_action( data : Dictionary )

@export var combatant : Combatant
@export var list : Node2D
var timer : Timer
const TACKLE = preload("res://src/moves/tackle.tres")

func act():
	if not timer.is_inside_tree(): return
	if not timer.is_stopped(): return
	if not combatant.active:return
	print("AI attacking...")
	timer.start()
	await timer.timeout
	var target
	for c in list.get_combatants():
		if not c == combatant:
			target = c
			break

	queue_action.emit(
		
		{
			"action": "attack",
			"actor": self,
			"params": [target, TACKLE],
		}
		
	)
		
	combatant.attack(target, TACKLE)

## Chooses between FIGHT or ITEM
func _evaluate_actions():pass
func _evaluate_item():pass
func _choose_move():pass
