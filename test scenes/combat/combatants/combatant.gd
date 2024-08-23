extends Node2D
class_name Combatant

signal turn_done
signal queue_action( data : Dictionary )
signal turn_start

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
	health = Health.new( data.get_stat("hp") )
	add_child(health)
	initiative = data.get_stat("spd")

#region actions
func attack( target : Combatant, move : BaseMove ):
	var dmg = _calculate_damage( target, move )
	$Sprite.play("attack")
	await $Sprite.animation_finished
	$Sprite.play("idle")
	target.take_damage( dmg )
	
	end_turn()

func consume(item):
	item.use( self )
	end_turn()

func flee():
	end_turn()
#endregion
func take_damage( amount ):
	prints(name, "took %.1f damage" % amount)
	health.take_damage( amount )
	# play hurt animation later

## Calculates damage based on the Gen1 formula
func _calculate_damage( target : Combatant, move : BaseMove ) -> int:
	var data := target.data
	var damage : int
	var AttackStat = 0
	var AD = 0
	var STAB = 1.0
	var WeakOrRes = 1
	match(move.dmg_type):
		BaseMove.DmgType.PHYSICAL, BaseMove.DmgType.SPECIAL:
			var atk = self.data.get_stat( move.dmg_key )
			var def = data.get_stat( move.dmg_key )
			
			AttackStat = atk
			AD = move.power/def
		_:
			AttackStat = 1
	
	#if data.get_types().has( Type.to_str(move.move_type) ):
		#STAB = 1.5
	#
	#WeakOrRes = Type.matchup(move.move_type, target.pokemon_data.get_types())
	
	randomize()
	var RandomNumber = randi_range(85, 100)
	
	damage = ((((2 * data.level / 5 + 2) * AttackStat * AD) / 50) + 2) * STAB * WeakOrRes * RandomNumber / 100
	return int(damage)

func end_turn():
	#await info_node.updated
	turn_done.emit()

# EOF #
