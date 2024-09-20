extends Node2D
class_name CombatantMonster

const PLAYER_GROUP = &"players"
const OPPONENT_GROUP = &"opponents"

signal action_queued

var active : bool = true :
	set(v):
		active = v
		set_process(v)
		set_process_input(v)
		if not active:
			return

var queued_action : CombatAction

var monster_data : Monster
var moves : Array[BaseMove]
var items : Array[Item]

var health : Health
var combat_sprite : Node2D

var initiative : float

func set_data( data : Monster ):
	assert(data.pid > -1)
	if data.captured_status == Monster.TAMED:
		add_to_group(PLAYER_GROUP)
	else:
		add_to_group(OPPONENT_GROUP)
	
	monster_data = data
	initiative = monster_data.get_stat( &"spd" ).value
	
	health = Health.new( monster_data.get_stat( &"hp" ) )
	health.combatant = self
	add_child(health)
	
	#combat_sprite = monster_data.combat_sprite.instantiate()
	#add_child(combat_sprite)

func queue_action( action : CombatAction ):
	queued_action = action
	active = false
	#print_debug("%s action queued" % name)
	CombatEvent.action_queued.emit( action, self )

func take_damage( amount, from = null, with = null ):
	monster_data.decrease_stat( &"hp", amount )
	health.take_damage( amount )
	#print_debug("%s took %d damage." % [ name, amount ])

#region COMBAT ACTIONS

func fight( target : CombatantMonster, move : BaseMove ):
	if not active: return
	var action = CombatAction.new( self, CombatAction.Actions.FIGHT, target, move )
	queue_action(action)

func use_item( item : Item ):
	if not active: return
	var action = CombatAction.new( self, CombatAction.Actions.USE_ITEM, self, item )
	queue_action(action)

func switch_with( target : Monster ):
	if not active: return
	var action = CombatAction.new( self, CombatAction.Actions.SWITCH, self, target )
	queue_action(action)

func flee():
	if not active: return
	var action = CombatAction.new( self, CombatAction.Actions.RUN )
	queue_action(action)

#endregion

# EOF #

func _ready():
	CombatEvent.round_start.connect(
		func():
			active = true
			#print_debug("round started, %s is active!" % name)
	)
	
	CombatEvent.ui_move_selected.connect(
		func(move):
			var target
			if self.is_in_group(PLAYER_GROUP):
				target = await CombatEvent.ui_target_selected
			else:
				target = get_tree().get_first_node_in_group(PLAYER_GROUP)
			fight(target, move)
	)
	CombatEvent.ui_item_selected.connect(
		func(item):
			#var target = await CombatEvent.ui_target_selected
			use_item(item)
	)
