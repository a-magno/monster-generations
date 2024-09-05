extends Resource
class_name BaseMove

signal move_used

enum Category {
	PHYSICAL,
	SPECIAL,
	STATUS_EFFECT
}

@export var id : StringName
@export var name : String
@export var max_uses : float = 0.0 :
	set(v):
		max_uses = v
		uses_left = max_uses
var uses_left :
	set(v):
		uses_left = clamp(v, 0, max_uses)
		if v > 0:
			move_used.emit()
@export var category : Category :
	set(t):
		category = t
		match(category):
			Category.PHYSICAL:
				dmg_key = &"atk"
				def_key = &"def"
			Category.SPECIAL:
				dmg_key = &"spAtk"
				def_key = &"spDef"
			Category.STATUS_EFFECT:
				dmg_key = &""
@export var power : float = 10.0
@export var accuracy : float = 100.0
var dmg_key : StringName
var def_key : String
@export var type : Typing.Types
@export_multiline var description : String
@export_range(-7, 5, 1) var priority : int = 0
func use_move(target : Combatant, user : Combatant):
	uses_left -= 1
	var dmg = _calculate_damage(target, user)
	await target.take_damage( dmg )
	
## Calculates damage based on the Gen1 formula
func _calculate_damage( target : Combatant, user : Combatant ) -> int:
	var data := target.data
	var damage : int
	var AttackStat = 0
	var AD = 0
	var STAB = 1.0
	var WeakOrRes = 1
	var level = data.level
	match(category):
		Category.PHYSICAL, Category.SPECIAL:
			var atk = user.data.get_stat( dmg_key ).get(&"value", 0.0)
			var def = data.get_stat( dmg_key ).get(&"value", 0.0)
			
			AttackStat = atk
			AD = power/def
		_:
			AttackStat = 1
	
	if type in data.get_typing():
		STAB = 1.5
	
	for t in target.data.get_typing():
		WeakOrRes += Typing.matchup( t, type)
	
	randomize()
	var RandomNumber = randi_range(85, 100)
	
	damage = ((((2 * level / 5 + 2) * AttackStat * AD) / 50) + 2) * STAB * WeakOrRes * RandomNumber / 100
	return int(damage)
