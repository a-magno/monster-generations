extends Node

signal wild_encounter_triggered( monsters : Array[Monster] )
signal npc_encounter_triggered( npc_data : Tamer )

signal battle_started()
signal battle_over( winner : Combatant, loser : Combatant )

signal turn_started( combatant : Combatant )
signal turn_ended( combatant : Combatant )

signal combatant_switched( combatant : Combatant, new_data : Monster )
