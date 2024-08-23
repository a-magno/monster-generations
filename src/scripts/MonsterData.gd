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
var nickname : StringName = "" :
	get():
		if not nickname.is_empty():
			return nickname
		return id.capitalize()
var captured_by : StringName
var captured_status = WILD
static var number_captured : int = 0
@export var genderless := false
var gender : Gender = 0
@export var evolvesInto : Monster
@export var nature : Nature
@export var type1 : Typing.Types
@export var type2 : Typing.Types

func get_typing():
	if type2:
		return [type1, type2]
	return [type1]

@export var ability : Resource #Change to Ability later

#region level
signal gained_exp( new_amount )
signal leveled_up( new_level )

var level : Level
#endregion

@export_category("Sprites")
@export var battle_scene : PackedScene
@export var icon : Texture
@export_subgroup("Moves")
## It is recommended to have multiple learnsets, such as a TM list and a level up list
@export var learnset : Array[Learnset]
var learned_moves : Array[BaseMove] #Change to Array[Move] later

@export_category("Statistics")
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
	var d : Monster = self.duplicate()
	d.is_instance = true
	d.gender = randi_range(1, 2) if not genderless else 0
	d.level = Level.new()
	
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
		d.stats[stat_id] = Stat.new(stat_id, base, d, formula)
		#print(d.stats[stat_id].value)
		
	
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

func get_stat(id : StringName):
	if id in stats:
		return {
			&"self" : stats[id],
			&"value" : stats[id].value,
			&"max" : stats[id].max_value
		}
	return 0.0

func get_level(as_data := false):
	if as_data:
		return {
			"current": level.level,
			"exp_cap": level.exp_cap,
			"curr_exp": level.curr_exp,
			"total": level.total_exp
		}
	return level.level

func decrease_stat(id, amount):
	if id in stats:
		stats[id].decrease(amount)

func increase_stat(id, amount):
	if id in stats:
		stats[id].increase(amount)

#region typing
func get_weaknesses():pass
func get_immunities():pass
func get_resistances():pass
#endregion
