extends Node2D
class_name CombatantMonster

signal action_queued

var active : bool = true :
	set(v):
		active = v
		set_process(v)
		set_process_input(v)
		print("%s active: %s" % [name, active])
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
	assert(data.initialized)
	if data.captured_status == Monster.TAMED:
		add_to_group(CombatHandler.PLAYER_GROUP)
	else:
		add_to_group(CombatHandler.OPPONENT_GROUP)
	
	monster_data = data
	initiative = monster_data.get_stat( &"spd" ).value
	
	health = Health.new( monster_data.get_stat( &"hp" ) )
	add_child(health)
	
	#combat_sprite = monster_data.combat_sprite.instantiate()
	#add_child(combat_sprite)

func queue_action( action : CombatAction ):
	queued_action = action
	action_queued.emit()

#region COMBAT ACTIONS

func fight( target : Combatant, move : BaseMove ):
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
