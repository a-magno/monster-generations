extends Node

signal wild_encounter_triggered( wild_monsters : Array )
signal npc_encounter_triggered( npc_data : Tamer )

signal battle_started()
signal battle_over( winner : CombatantMonster, loser : CombatantMonster )

signal turn_started( combatant : CombatantMonster )

signal action_queued( action : CombatAction, actor : CombatantMonster )
signal item_used( item : Item, target : CombatantMonster )
signal attempt_flee()

signal combatant_switched( combatant : CombatantMonster, new_data : Monster )
signal combatant_dead( combatant : CombatantMonster )


signal turn_ended( combatant : CombatantMonster )
signal round_start()
signal round_over()

#region from UI
signal ui_item_selected( item : Item )
signal ui_move_selected( move : BaseMove )
signal ui_target_selected( target : CombatantMonster)
#endregion

#region to UI
signal action_fight()
signal action_item()
signal action_switch()
signal action_run()
signal exp_updated()
signal hp_updated()
#endregion
