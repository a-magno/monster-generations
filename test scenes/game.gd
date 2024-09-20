extends Node

@export var battle_scene : Node2D
@export var world : Node2D
#@onready var party_list = $"World/WorldUI/Party List"

func _ready():
	CombatEvent.wild_encounter_triggered.connect(_start_wild_battle)
	CombatEvent.npc_encounter_triggered.connect(_start_npc_battle)
	CombatEvent.battle_over.connect(_on_battle_finished)
	remove_child(battle_scene)
	
	#var starter = await MonsterManager.generate_tamed_monster( MonsterManager.monsters.keys().pick_random(), "", 5)
	#PlayerData.add_to_party( starter )
	
	#for monster in PlayerData.party:
		#print(JSON.stringify( monster.serialize(), "\t") )

	#for c in party_list.get_children():
		#c.queue_free()
	#for member in PlayerData.party:
		#var mon_slot = MONSTER_SLOT.instantiate()
		#party_list.add_child( mon_slot )
		#mon_slot.set_data(member)

func _start_wild_battle( monsters : Array ):
	WorldTime.pause()
	PlayerData.set_player_state( Player.BATTLING )
	monsters.push_front(PlayerData.get_party_leader())
	
	await _fade_out()
	remove_child(world)
	add_child( battle_scene )
	battle_scene.show()
	battle_scene.begin_combat(monsters)
	await _fade_in()
	

func _start_npc_battle( opponent : Tamer ):
	WorldTime.pause()
	PlayerData.set_player_state( Player.BATTLING )
	
	var combatants = opponent.party
	for combatant in combatants:
		if not combatant.is_instance:
			combatant = await combatant.initialize()

	combatants.push_front(PlayerData.get_party_leader())
	#combatants.push_back( combatant )

	await _fade_out()
	remove_child(world)
	add_child( battle_scene )
	battle_scene.show()
	battle_scene.start_battle(combatants)
	await _fade_in()

func _on_battle_finished(winner, loser):
	remove_child(battle_scene)
	add_child(world)
	_fade_in()
	WorldTime.pause(false)
	
	if winner.is_in_group(CombatantMonster.PLAYER_GROUP):
		print("Player Win")
	else:
		print("Player Lost")
	##TODO
	##gain loot
	##check for evolutions
	
	#await animation player finished for...something
	#var player = PlayerData.get_player()
	#play some dialogue
	battle_scene.clear_combat()
	PlayerData.set_player_state( Player.IDLE )

#region Animations
func _fade_out():
	#play fade in anim
	$AnimationPlayer.play("fade")
	#wait for anim finished
	await $AnimationPlayer.animation_finished

func _fade_in():
	#play fade out
	$AnimationPlayer.play_backwards("fade")
	#wait for anim finished
	await $AnimationPlayer.animation_finished
#endregion
