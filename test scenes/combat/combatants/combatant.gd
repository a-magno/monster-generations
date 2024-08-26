extends Node2D
class_name Combatant

signal turn_done
signal queue_action( data : Dictionary )
signal turn_start

enum CombatantState {
	ALIVE,
	PARALYZED,
	FROZEN,
	ASLEEP,
	FAINTED
}

@export var data : Monster
var initiative

var active : bool = false : set = _set_active
#region Nodes
var health : Health
var battle_sprite : PackedScene
#endregion

func _set_active(value):
	active = value
	set_process(value)
	set_process_input(value)
	if not active:
		return
	print("%s turn started." % name)
	turn_start.emit()

func set_data(_data : Monster):
	data = _data
	health = Health.new( data.get_stat(&"hp") )
	health.combatant = self
	add_child(health)
	initiative = data.get_stat(&"spd").value

#region actions
func attack( target : Combatant, move : BaseMove ):
	if not active: return
	$Sprite.play("attack")
	await move.use_move( target, self )
	await $Sprite.animation_finished
	$Sprite.play("idle")
	end_turn()

func consume(item):
	item.use( self )
	end_turn()

func switch( tag_in : Monster ):
	end_turn()

func flee():
	end_turn()
#endregion

func take_damage( amount ):
	data.decrease_stat(&"hp", amount)
	await health.take_damage( amount )
	#prints(name, "took %d damage" % amount)
	# play hurt animation later

func end_turn():
	#await info_node.updated
	turn_done.emit()

# EOF #
