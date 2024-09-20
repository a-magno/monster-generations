extends CanvasLayer

const COMBATANT_INFO = preload("res://src/scenes/ui/battle/info/combatant_info.tscn")
@onready var combatant_ui = $"InfoPanels/Combatant UI"
@onready var combatants = $"../Combatants"
@onready var turn_queue = $"../TurnQueue"


@onready var combat_actions = $Actions/CombatActions
@onready var move_container = $Actions/MoveContainer

var player : CombatantMonster

func _ready():
	CombatEvent.action_fight.connect(
		func():
			$Actions/CombatActions.hide() 
			$Actions/MoveContainer.show()
			)
	CombatEvent.action_item.connect( func(): pass )
	CombatEvent.action_switch.connect( func(): pass )
	CombatEvent.turn_ended.connect( 
		func(actor):
			if actor.is_in_group(CombatantMonster.PLAYER_GROUP):  
				$Actions.hide()
			)
	CombatEvent.ui_target_selected.connect(	func(t):$Actions/CombatActions.hide() )
	CombatEvent.round_start.connect( 
		func():
			#await CombatEvent.hp_updated
			$Actions/CombatActions.show()
			)
	CombatEvent.ui_move_selected.connect(func(m):$Actions/MoveContainer.hide())

func player_setup( combatant : CombatantMonster ):
	player = combatant

func clear():
	for child in combatant_ui.get_children():
		child.queue_free()

func setup_panel( combatant : CombatantMonster ):
	var info_panel = COMBATANT_INFO.instantiate()
	combatant_ui.add_child( info_panel )
	info_panel.set_data(combatant)

func setup_actions():
	#Connect to monster menu for position_changed signal
	#Connect to inventory's item_used signal
	CombatEvent.ui_item_selected.connect(_on_item_selected)
	pass

func setup_moves( moves : Array[BaseMove]):
	move_container.populate_with_moves( moves )

#region SIGNALS
func _on_move_selected(move : BaseMove, actor : CombatantMonster, target : CombatantMonster):
	#var target = get_tree().get_first_node_in_group(CombatantMonster.OPPONENT_GROUP)
	#actor.fight(target, move)
	#CombatEvent.move_selected.emit(move, actor, target)
	if actor.is_in_group(CombatantMonster.PLAYER_GROUP):
		$Actions.hide()

func _on_item_selected( item : Item ):
	var target = await CombatEvent.ui_target_selected
	CombatEvent.item_used.emit( item, target )
#endregion
