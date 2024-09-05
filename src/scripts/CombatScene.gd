extends Node2D

@export var turn_queue : Node
@export var combatants : Node2D
@export var battle_ui : CanvasLayer

func begin_combat(monsters : Array[Monster]):
	turn_queue.round_over.connect( player_turn )
	
	for monster in monsters:
		setup( monster )

func setup( monster : Monster )->void:
	print_debug(monster.nickname)
	monster = monster if monster.initialized else monster.initialize()
	
	var combatant = CombatantMonster.new()
	combatant.set_data( monster )
	combatants.add_combatant( combatant )
	
	combatant.action_queued.connect(turn_queue._check_all_inactive)
	turn_queue.round_over.connect( func(): combatant.active = true )

func player_turn()->void:
	#battle_ui.activate()
	pass

func battle_over(winner, loser)->void:
	pass
