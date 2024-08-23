extends Resource
class_name Monster

enum Gender {
	UNKNOWN,
	MALE,
	FEMALE
}

enum {
	WILD,
	TAMED,
	NPC_TAMED,
	BOSS
}

#var id, species, type, nickname, level, stats, ability, learnset, learned_move
var is_instance := false
@export_category("Information")
@export var id : StringName
var nickname : StringName = ""
var captured_by : StringName
var captured_status = WILD
static var number_captured : int = 0
@export var genderless := false
var gender : Gender = 0
@export var evolvesInto : Monster
@export var nature : Nature
@export var type1 : Typing.Types = 0
@export var type2 : Typing.Types = 0
@export var ability : Resource #Change to Ability later

#region level
signal gained_exp( new_amount )
signal leveled_up( new_level )

var level : int = 1
var exp_cap : int = 0
var exp : int = 0
var total_exp : int = 0
#endregion

@export_category("Sprites")
@export var battle_scene : PackedScene
@export var icon : Texture
@export_subgroup("Moves")
## It is recommended to have multiple learnsets, such as a TM list and a level up list
@export var learnset : Array[Learnset]
var learned_moves : Array[BaseMove] #Change to Array[Move] later

@export_category("Statistics")
class Stat:
	var id: StringName
	var owner : Monster
	var formula_override = null
	var base : float = 0.0
	var value : float = 0.0
	var EV : float = 0.0
	var IV : float = 0.0
	var add : float = 0.0
	var mult : float = 0.0
	func _init(_id : StringName, _base : float, _o : Monster, _formula = null):
		id = _id
		owner = _o
		base = _base
		formula_override = _formula
		randomize()
		IV = float(randi_range(1, 15))
		value = calculate(formula_override)
		#print("%s : %.0f" % [_id, value])
		
	func calculate(formula_override = self.formula_override) -> float:
		value = base
		var expr = Expression.new()
		var inputs = {
			"IV": int(IV),
			"EV": int(EV),
			"base": base,
			"level": owner.level,
			#"nature" : owner.nature.get_mod(id)
		}
		#print(JSON.stringify(inputs, "\t", false))
		var formula = "(((IV + 2 * base + (EV/4) ) * level/100 ) + 5)" # * nature
		if formula_override:
			formula = formula_override
		var parse_res = expr.parse(formula, inputs.keys())
		if parse_res != OK:
			print(expr.get_error_text())
			return 0.0
		var res = expr.execute(inputs.values())
		if expr.has_execute_failed():
			return 0.0
		value = res
		value = (value + add) * (1.0 + mult)
		return int(value)

@export var hp_base : float = 0.0
@export var atk_base : float = 0.0
@export var def_base : float = 0.0
@export var spAtk_base : float = 0.0
@export var spDef_base : float = 0.0
@export var spd_base : float = 0.0

## Stats as a dictionary will be responsible for holding EVs, IVs, and growth values

var stats : Dictionary = {}

## Initialization for randomizing IVs, nature and moves
func initialize():
	randomize()
	if not genderless:
		gender = randi_range(1, 2)
	var d : Monster = self.duplicate()
	d.is_instance = true
	var base_values = {
		&"hp": [hp_base, "( (IV + 2 * base + (EV/4) ) * level/100 ) + 10 + level"],
		&"atk": [atk_base, null],
		&"def": [def_base, null],
		&"spAtk": [spAtk_base, null],
		&"spDef": [spDef_base, null],
		&"spd": [spd_base, null]
	}
	for stat_id in base_values.keys():
		var base = base_values[stat_id][0]
		var formula = base_values[stat_id][1]
		d.stats[stat_id] = Stat.new(stat_id, base, self, formula)
		#print(d.stats[stat_id].value)
	
	d.exp_cap = _calculate_exp_to_next_level(d.level)
	
	return d

## Duplicates the resouce of a 'wild' monster, so it can be added to the player's roster
func acquire(new_nickname : String):
	var acquired_monster = initialize()
	if new_nickname.length() > 0:
		acquired_monster.nickname = new_nickname
	acquired_monster.captured_by = PlayerData.player_name
	for stat_id in acquired_monster.stats.keys():
		if acquired_monster.stats[stat_id].value == 0.0:
			acquired_monster.stats[stat_id].calculate()
	#acquired_monster.recalculate_stats(acquired_monster)
	return acquired_monster 

func get_stat(id : StringName) -> float:
	if id in stats:
		return stats[id].value
	return 0.0

func get_nickname():
	return nickname if nickname.length() > 0 else id.capitalize()

#region leveling up
func gain_exp( exp_gained: int, monster: Monster = self ) -> void:
	monster.exp += exp_gained
	monster.total_exp += exp_gained
	handle_level_ups(monster)
	print("%s gained %d EXP!" % [monster.get_nickname(), exp_gained])
	gained_exp.emit(exp_gained)

func handle_level_ups(monster: Monster = self) -> void:
	while _can_level_up(monster.exp, monster.level):
		level_up(monster)

func level_up(monster : Monster = self, discrete := true):
	monster.level += 1
	monster.exp -= _calculate_exp_to_next_level(monster.level - 1)
	monster.recalculate_stats(monster)
	if not discrete:
		print("%s leveled up to level %d!" % [monster.get_nickname(), monster.level])
	leveled_up.emit(monster.level)

func recalculate_stats(monster: Monster = self) -> void:
	for stat_id in monster.stats.keys():
		#if monster.stats[stat_id].value == 0.0:
		var formula = monster.stats[stat_id].formula_override
		#print_debug("Stat %s formula: %s\n" % [stat_id, formula])
		monster.stats[stat_id].owner = monster
		monster.stats[stat_id].calculate(formula)

func _calculate_exp_to_next_level(current_level: int = self.level) -> int:
	# Example formula, can be customized
	return 100 * current_level

func _can_level_up(current_exp: int, current_level: int) -> bool:
	var exp_to_next_level = _calculate_exp_to_next_level(current_level)
	return current_exp >= exp_to_next_level
#endregion

#region typing
func get_weaknesses():pass
func get_immunities():pass
func get_resistances():pass
func _get_type_data():
	if type2 == Typing.Types.NULL:
		return Typing.type_matchups[type2]
	return Typing.type_matchups[type1].merge( Typing.type_matchups[type2] )
#endregion
