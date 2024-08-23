extends Control

signal update_over
signal combatant_dead(combatant)

const MONSTER_INFO = preload("res://test scenes/combat/UI/monster_info.tscn")
@onready var combatants_list: Node2D = $"../Combatants"
@onready var combatant_ui: HBoxContainer = $"MarginContainer/Combatant UI"

func start():
	for combatant : Combatant in combatants_list.get_combatants():
		var info = MONSTER_INFO.instantiate()
		#info.health_node = combatant.health
		info.combatant = combatant
		combatant_ui.add_child(info)
		info.set_healthbar(combatant.health)
		info.set_data( combatant.data )
		info.updated.connect(_on_info_updated)
		combatant.health.dead.connect(_on_combatant_death)

func free_info_nodes():
	for c in combatant_ui.get_children():
		c.queue_free()

func _on_attack_pressed() -> void:
	print_debug("enter attack pressed")
	if not combatants_list.get_node("Player").active:
		print_debug("not player turn")
		return
	var test_move = load("res://src/moves/tackle.tres")
	combatants_list.get_node("Player").attack( combatants_list.get_node("Opponent"), test_move )

func _on_use_item_pressed() -> void:
	if not combatants_list.get_node("Player").active:
		return
	print(PlayerData.inventory)

func _on_party_pressed() -> void:
	if not combatants_list.get_node("Player").active:
		return
	print(PlayerData.party)

func _on_flee_pressed() -> void:
	if not combatants_list.get_node("Player").active:
		return
	combatants_list.get_node("Player").flee()
	var loser = combatants_list.get_node("Player")
	var winner = combatants_list.get_node("Opponent")
	get_parent().finish_combat(winner, loser)

func _on_active_changed(active_combatant: Combatant) -> void:
		for c in $Control/GridContainer.get_children():
			c.disabled = !active_combatant.name == "Player"

func _on_info_updated(combatant : Combatant):
	update_over.emit()

func _on_combatant_death(combatant : Combatant):
	await update_over
	combatant_dead.emit(combatant)
