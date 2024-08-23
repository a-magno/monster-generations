extends Node
class_name Health

signal dead( combatant )
signal health_changed( new_value )

var data : Monster

var value : int : 
	set(v):
		value = v
		health_changed.emit(value)
var max_value : int

func _init(_data):
	data = _data
	max_value = data.get_stat(&"hp").max_value
	value = data.get_stat(&"hp").value

func take_damage( amount ):
	data.decrease_stat(&"hp", amount)
	value = data.get_stat(&"hp").value
	if value <= 0:
		#clamp(value, 0, max_value)
		dead.emit( get_parent() )

func heal( amount ):
	data.increase_stat(&"hp", amount)
	value = data.get_stat(&"hp").max_value
