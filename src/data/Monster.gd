extends MonsterCore
class_name MonsterData

#region signals
signal leveled_up( level )
signal gained_exp( amount )
#endregion

#region enums
enum Gender {UNKNOWN,MALE,FEMALE}
const SPECIAL_THRESHOLDS = [0, 254, 255]
enum {WILD,TAMED,NPC_TAMED,BOSS}
enum StatusCondition {SLEEP, BURN, PARALYZE, POISON, FREEZE}
#endregion

#region attributes
var nickname : String :	get = get_nickname
var PID : int

var level : int = 1: set = set_level
var experience : int = 0
var experience_total : int = 0
var experience_required : int = get_required_exp(1)

var gender : Gender
var trainer_id : int
var trainer_name : String

var nature
var ability : Ability

var stats : Dictionary

#endregion

func get_nickname():
	return id.to_upper() if nickname.length() <= 0 else nickname.capitalize()

#region initialization logic
func initialize():
	var monster = duplicate(true) as MonsterData
	monster.PID = randi()
	#Set Gender
	print(SPECIAL_THRESHOLDS.has(gender_threshold))
	if SPECIAL_THRESHOLDS.has(gender_threshold):
		monster.gender = Gender.UNKNOWN
	else:
		monster.gender = Gender.MALE if randi_range(1, 252) > gender_threshold else Gender.FEMALE
	#Set Nature
	#Set Ability
	#Set Stats
	_calculate_stats(monster)
	return monster

func _calculate_stats( monster : MonsterCore ):
	var base_values = {
		&"hp": [base_hp, MonsterCore.CoreStats.hp.formula],
		&"atk": [base_atk, null],
		&"def": [base_def, null],
		&"spAtk": [base_spAtk, null],
		&"spDef": [base_spDef, null],
		&"spd": [base_spd, null]
	}
	for stat in MonsterCore.CoreStats.keys():
		var base = base_values[stat][0]
		var formula = base_values[stat][1]
		monster.stats[stat] = Stat.new(stat, base, monster, formula)

#endregion
#region level logic
func set_level( lvl ):
	level = max(lvl, 1)
	experience_required = get_required_exp(level+1)
	leveled_up.emit(lvl)

func get_required_exp( level ):
	match( growth_type ):
		Level.GrowthTypes.FAST:
			return Level.fast( level )
		Level.GrowthTypes.MEDIUM_FAST:
			return Level.medium_fast( level )
		Level.GrowthTypes.MEDIUM_SLOW:
			return Level.medium_slow( level )
		Level.GrowthTypes.SLOW:
			return Level.slow( level )
		_:
			return Level.slow(level)

func gain_experience( amount ):
	experience_total += amount
	experience += amount
	var growth_data = []
	while experience >= experience_required:
		experience -= experience_required
		growth_data.append([experience_required, experience_required])
		level_up()
	growth_data.append([experience, experience_required])
	gained_exp.emit( growth_data )

func level_up():
	level += 1
	#handle learning new move
	#learn_moves(&"level_up", level)
#endregion
