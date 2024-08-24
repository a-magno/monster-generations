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
	var dmg = _calculate_damage( target, move )
	$Sprite.play("attack")
	await $Sprite.animation_finished
	$Sprite.play("idle")
	await target.take_damage( dmg )
	
	end_turn()

func consume(item):
	item.use( self )
	end_turn()

func flee():
	end_turn()
#endregion

func take_damage( amount ):
	data.decrease_stat(&"hp", amount)
	await health.take_damage( amount )
	prints(name, "took %.1f damage" % amount)
	# play hurt animation later

## Calculates damage based on the Gen1 formula
func _calculate_damage( target : Combatant, move : BaseMove ) -> int:
	var data := target.data
	var damage : int
	var AttackStat = 0
	var AD = 0
	var STAB = 1.0
	var WeakOrRes = 1
	var level = data.get_level()
	match(move.dmg_type):
		BaseMove.DmgType.PHYSICAL, BaseMove.DmgType.SPECIAL:
			var atk = self.data.get_stat( move.dmg_key ).value
			var def = data.get_stat( move.dmg_key ).value
			
			AttackStat = atk
			AD = move.power/def
		_:
			AttackStat = 1
	
	if move.type in data.get_typing():
		STAB = 1.5
	
	for t in target.data.get_typing():
		WeakOrRes += Typing.matchup( t, move.type)
	
	randomize()
	var RandomNumber = randi_range(85, 100)
	
	damage = ((((2 * level / 5 + 2) * AttackStat * AD) / 50) + 2) * STAB * WeakOrRes * RandomNumber / 100
	return int(damage)

func end_turn():
	#await info_node.updated
	turn_done.emit()

# EOF #
