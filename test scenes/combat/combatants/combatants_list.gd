extends Node2D

var combatants = []

func add_combatant( new_combatant : Combatant ):
	add_child(new_combatant)
	if new_combatant.data.captured_status == Monster.TAMED:
		new_combatant.add_to_group(CombatHandler.PLAYER_GROUP)
		new_combatant.scale = $PlayerMarker.scale
		new_combatant.global_position = $PlayerMarker.global_position
		
	else:
		new_combatant.name = "Opponent"
		new_combatant.add_to_group(CombatHandler.OPPONENT_GROUP)
		new_combatant.global_position = $OpponentMarker.global_position
	combatants.append(new_combatant)
	#add_child(new_combatant)

func get_combatants():
	return combatants
