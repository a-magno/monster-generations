extends CanvasLayer

signal update_over

const MONSTER_INFO = preload("res://test scenes/combat/UI/monster_info.tscn")
const MOVE_BUTTON = preload("res://src/scenes/ui/move select/option/button.tscn")

@onready var combatants_list: Node2D = $"../Combatants"
@onready var combatant_ui: HBoxContainer = $"MarginContainer/Combatant UI"
@onready var actions = %Actions
@onready var move_list = %MoveList

func _ready():
	move_list.hide()
	for c in move_list.get_children():
		c.queue_free()

func start():
	for combatant : Combatant in combatants_list.get_combatants():
		var info = MONSTER_INFO.instantiate()
		combatant_ui.add_child(info)
		info.combatant = combatant
		info.updated.connect(_on_info_updated)
		if combatant.data.captured_status == Monster.TAMED:
			var moves = combatant.data.get_battle_moves()
			moves.reverse()
			for move in moves:
				var move_btn = MOVE_BUTTON.instantiate()
				move_list.add_child(move_btn)
				move_btn.set_data(move)
				move_btn.move_selected.connect(_on_move_selected)

func free_info_nodes():
	for c in combatant_ui.get_children():
		c.queue_free()

func _on_attack_pressed() -> void:
	#print_debug("enter attack pressed")
	if not combatants_list.get_node("Player").active:
		#print_debug("not player turn")
		return
	actions.hide()
	move_list.show()

func _on_move_selected( move : BaseMove):
	var target = combatants_list.get_node("Opponent")
	var user = combatants_list.get_node("Player")
	move.use_move(target, user)
	move_list.hide()
	actions.show()
	

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
		for c in actions.get_children():
			c.disabled = !active_combatant.name == "Player"

func _on_info_updated(combatant : Combatant):
	update_over.emit()
	print("UI Update over...")
