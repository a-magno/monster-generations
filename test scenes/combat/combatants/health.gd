extends Node
class_name Health

signal dead( combatant )
signal health_changed( new_value )

var value : int : 
	set(v):
		value = v
		health_changed.emit(value)
var max_value : int

func _init(stat):
	max_value = max(stat.max_value, stat.value)
	value = stat.value

func take_damage( amount ):
	value -= max(amount, 1)
	if value <= 0:
		clamp(value, 0, max_value)
		dead.emit( get_parent() )

func heal( amount ):
	value += max(amount, 0)
