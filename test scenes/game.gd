extends Node

@export var battle_scene : Node2D
@export var world : Node2D
#@onready var party_list = $"World/WorldUI/Party List"

func _ready():
	CombatHandler.wild_encounter_triggered.connect(_start_wild_battle)
	CombatHandler.npc_encounter_triggered.connect(_start_npc_battle)
	CombatHandler.battle_over.connect(_on_battle_finished)
	remove_child(battle_scene)
	
	var starter = MonsterManager.generate_tamed_monster( MonsterManager.monsters.keys().pick_random(), "Pika de Fogo", 5)
	PlayerData.add_to_party( starter )
#
	#for c in party_list.get_children():
		#c.queue_free()
	#for member in PlayerData.party:
		#var mon_slot = MONSTER_SLOT.instantiate()
		#party_list.add_child( mon_slot )
		#mon_slot.set_data(member)

func _start_wild_battle( monsters : Array ):
	WorldTime.pause()
	PlayerData.player_instance.state = Player.BATTLING
	monsters.push_front(PlayerData.get_party_leader())
	
	await _fade_out()
	remove_child(world)
	add_child( battle_scene )
	battle_scene.show()
	await _fade_in()
	battle_scene.start_battle(monsters)
	

func _start_npc_battle( opponent : Tamer ):
	WorldTime.pause()
	PlayerData.player_instance.state = Player.BATTLING
	
	var combatants = opponent.party
	for combatant in combatants:
		if not combatant.is_instance:
			combatant = combatant.initialize()

	combatants.push_front(PlayerData.get_party_leader())
	#combatants.push_back( combatant )

	await _fade_in()
	remove_child(world)
	add_child( battle_scene )
	battle_scene.show()
	await _fade_out()
	battle_scene.start_battle(combatants)

func _on_battle_finished(winner, loser):
	remove_child(battle_scene)
	add_child(world)
	_fade_in()
	WorldTime.pause(false)
	
	if winner.name == "Player":
		print("Player Win")
	else:
		print("Player Lost")
	##TODO
	##gain loot
	##check for evolutions
	
	#await animation player finished for...something
	var player = PlayerData.get_player()
	#play some dialogue
	battle_scene.clear_combat()
	PlayerData.player_instance.state = Player.IDLE

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
