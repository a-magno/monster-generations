extends Node2D

const AI = preload("res://src/scripts/wild_ai.gd")

@export var turn_queue : Node
@export var combatants : Node2D
@export var battle_interface : CanvasLayer

func _process(delta):
	$BattleInterface/Label.text = str(turn_queue.round_count)

func begin_combat(monsters : Array[Monster]):
	CombatEvent.combatant_dead.connect(_on_combatant_death)
	battle_interface.clear()
	for monster in monsters:
		setup( monster )

func clear_combat():
	combatants.free_combatants()
	battle_interface.clear()

func setup( monster : Monster )->void:
	#print_debug(monster.nickname)
	monster = monster if monster.pid > -1 else monster.initialize()
	
	var combatant = CombatantMonster.new()
	combatant.set_data( monster )
	combatants.add_combatant( combatant )
	# Connect to signals
	if not CombatEvent.round_over.is_connected(_on_round_over):
		CombatEvent.round_over.connect( _on_round_over )
	
	# Set up Battle Interface for current combatant
	battle_interface.setup_panel( combatant )
	if combatant.is_in_group( CombatantMonster.PLAYER_GROUP ):
		battle_interface.player_setup( combatant )
		#battle_interface.setup_moves( monster.get_battle_moves() )
	else:
		var wild_ai = AI.new()
		wild_ai.combatant = combatant
		combatant.add_child(wild_ai)

func battle_over(winner, loser)->void:
	battle_interface.clear()
	turn_queue.clear()
	CombatEvent.combatant_dead.disconnect(_on_combatant_death)
	CombatEvent.battle_over.emit(winner, loser)

func _on_round_over():
	CombatEvent.round_start.emit()

func _on_combatant_death( combatant : CombatantMonster ):
	if combatant.is_in_group(CombatantMonster.PLAYER_GROUP):
		combatant.remove_from_group(CombatantMonster.PLAYER_GROUP)
	else:
		combatant.remove_from_group(CombatantMonster.OPPONENT_GROUP)
	
	var player_group = get_tree().get_nodes_in_group(CombatantMonster.PLAYER_GROUP)
	var opponent_group = get_tree().get_nodes_in_group(CombatantMonster.OPPONENT_GROUP)
	
	#if check_for_tag_ins(combatant):
		##This is where switch logic goes
		#
		##--
		#pass

	var winner
	var loser
	if player_group.size() > opponent_group.size():
		winner = player_group[0]
		loser = combatant
		give_exp( winner, loser )
		await CombatEvent.exp_updated
	else:
		loser = player_group[0]
		winner = combatant
	battle_over(winner, loser)

func give_exp( to : CombatantMonster, from : CombatantMonster ):
	if not to.is_in_group(&"players"):
		return
	#Experience = ((Base Experience * Level) * Trainer * Wild) / 7
	var data : Monster = from.monster_data
	var is_wild = 1.5 if data.captured_status == Monster.NPC_TAMED else 1.0
	var worth = data.base_exp_worth
	var exp = roundf(( worth * data.level * is_wild) / 7)
	to.monster_data.gain_experience( exp )
	print("%s gained %d EXP." % [to.monster_data.nickname, exp])
