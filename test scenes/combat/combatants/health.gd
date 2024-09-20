extends Node
class_name Health

signal dead( combatant )
signal health_changed( new_value )

@onready var combatant : CombatantMonster

var value : float : 
	set(v):
		value = v
		health_changed.emit(value)
var max_value : float

func _init( stat : Dictionary ):
	max_value = stat.max
	value = stat.value
	name = "Health"

func take_damage( amount ):
	#value -= max(amount, 1)
	await _tween_amount( -amount )
	if value <= 0:
		combatant.active = false
		# TODO: Replace with death anim later
		#await get_tree().create_timer(1.0).timeout
		
		CombatEvent.combatant_dead.emit( combatant )
		

func heal( amount ):
	value += max(amount, 0)

func _tween_amount( amount ):
	var tween = create_tween()
	var target_v = clamp(value+amount, 0, max_value)
	tween.tween_property(self, "value", target_v, 0.4)
	await tween.finished
	CombatEvent.hp_updated.emit()
