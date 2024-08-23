extends Node2D

var combatants = []

func add_combatant( new_combatant : Combatant ):
	if new_combatant.name == "Player":
		add_child(new_combatant)
		#new_combatant.get_node("Sprite").flip_h = false
		new_combatant.scale = $PlayerMarker.scale
		new_combatant.global_position = $PlayerMarker.global_position
		
	else:
		add_child(new_combatant)
		new_combatant.name = "Opponent"
		new_combatant.global_position = $OpponentMarker.global_position
	combatants.append(new_combatant)
	#add_child(new_combatant)

func get_combatants():
	return combatants
