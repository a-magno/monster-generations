extends Node

var test_nickanmes = ["Biscuit", "Boba"]
@export var battle_scene : Node2D
@export var world : Node2D

func _ready():
	battle_scene.battle_over.connect(_on_battle_finished)
	world.encounter_triggered.connect(start_battle)
	remove_child(battle_scene)
	
	var starter = MonsterManager.generate_tamed_monster( MonsterManager.monsters.keys().pick_random(), test_nickanmes.pick_random(), 5)
	PlayerData.add_to_party( starter )

	var party_list : HBoxContainer = HBoxContainer.new()
	$World/WorldUI.add_child( party_list )
	for member in PlayerData.party:
		var text_rect = TextureRect.new()
		text_rect.texture = member.icon
		party_list.add_child( text_rect )

func start_battle( combatant : Monster ):
	PlayerData.player_instance.state = Player.States.BATTLING
	
	var combatants = []
	if not combatant.is_instance:
		combatant = combatant.initialize()

	combatants.push_back(PlayerData.get_party_leader())
	combatants.push_back( combatant )

	#play fade in anim
	$AnimationPlayer.play("fade")
	#wait for anim finished
	await $AnimationPlayer.animation_finished
	remove_child(world)
	add_child( battle_scene )
	battle_scene.show()
	battle_scene.start_battle(combatants)
	#play fade out
	$AnimationPlayer.play_backwards("fade")

func _on_battle_finished(winner, loser):
	
	remove_child(battle_scene)
	#play fade in animation
	$AnimationPlayer.play_backwards("fade")
	add_child(world)
	
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
	PlayerData.player_instance.state = Player.States.IDLE

func _on_tree_exiting() -> void:
	print_orphan_nodes()
