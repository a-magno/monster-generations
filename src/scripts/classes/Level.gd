extends RefCounted
class_name Level

signal gained_exp( new_amount )
signal leveled_up( new_level )

enum Growth {
	FAST,
	MEDIUM_FAST,
	MEDIUM_SLOW,
	SLOW
}

var level : int = 1
var owner : Monster
var growth : Growth
var exp_required : int = 0
var experience : int = 0 :
	set(v):
		#print_debug(v)
		experience = v
var experience_total : int = 0 :
	set(v):
		experience_total = v

func _init( _o : Monster, starting_level : int, growth_type : Growth = Growth.FAST):
	owner = _o
	growth = growth_type
	exp_required = _calculate_exp_to_next_level( growth, starting_level+1 )
	leveled_up.connect(owner._on_level_up)
	while level < starting_level:
		gain_exp( exp_required, owner )

#region
func gain_exp( amount, monster: Monster ) -> void:
	experience += amount
	experience_total += amount
	gained_exp.emit(experience)
	await handle_level_ups(monster)
	print_debug("%s gained %d EXP!" % [monster.nickname, amount])

func handle_level_ups( monster: Monster ) -> void:
	while _can_level_up():
		experience -= exp_required
		level_up(monster)
		owner.move_learned

func level_up(monster : Monster, discrete := false):
	level += 1
	exp_required = _calculate_exp_to_next_level( self.growth, level+1 )
	#recalculate_stats(monster)
	if not discrete:
		print_debug("%s leveled up to level %d!" % [monster.nickname, level])
		#print_debug("level: %d\nexp: %d" % [level, experience])
	leveled_up.emit(level)
	
func recalculate_stats(monster: Monster) -> void:
	for stat_id in monster.stats.keys():
		#if monster.stats[stat_id].value == 0.0:
		var stat : Stat = monster.stats[stat_id]
		#var formula = stat.formula_override
		stat.owner = monster
		stat.max_value = stat.calculate()
		#stat.value = stat.max_value - stat.value

func _calculate_exp_to_next_level(_growth : Growth, current_level: int = level) -> int:
	# Example formula, can be customized
	match( _growth ):
		Growth.FAST:
			return _fast( current_level )
		Growth.MEDIUM_FAST:
			return _medium_fast( current_level )
		Growth.MEDIUM_SLOW:
			return _medium_slow( current_level )
		Growth.SLOW:
			return _slow( current_level )
		_:
			return _slow(current_level)

func _can_level_up() -> bool:
	return experience >= exp_required and experience != 0
#endregion

#region FUNCTIONS

func _fast( n ):
	return 0.8 * pow(n, 3)

func _medium_fast( n ):
	return pow(n, 3)

func _medium_slow( n ):
	return 1.2*pow(n, 3) - (15 * pow(n, 2)) + 100*n - 140

func _slow( n ):
	return 1.25 * pow(n, 3)

#endregion
