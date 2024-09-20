extends Resource
class_name Monster

signal move_learned( move )

enum Gender {UNKNOWN,MALE,FEMALE}
enum {WILD,TAMED,NPC_TAMED,BOSS}
enum StatusCondition {SLEEP, BURN, PARALYZE, POISON, FREEZE}

var pid : int = -1
@export var id : StringName
@export_category("Information")
var nickname : StringName = "" :
	get():
		if not nickname.is_empty():
			return nickname
		return id.capitalize()
var original_trainer : StringName
var trainer_id : int #Original Trainer ID
var _secret_trainer_id : int # OT ID but secret
var captured_status = WILD
var friendship : float = 0.0
@export var genderless := false
var gender : Gender = 0
@export var evolvesInto : Monster
@export var nature : Nature

#region typing
@export var type1 : Typing.Types
@export var type2 : Typing.Types

func matchup( atk_type : Typing.Types ):
	var total = 0.0
	total += Typing.matchup(type1, atk_type)
	if type2:
		total += Typing.matchup(type2, atk_type)
	return total

func get_typing():
	if type2:
		return [type1, type2]
	return [type1]
#endregion

@export var ability : Resource #Change to Ability later

#region level
signal gained_exp( data : Array )
signal leveled_up( new_level )

@export var growth_type : Level.GrowthTypes = Level.GrowthTypes.FAST
var level : int = 1: 
	set(v):
		level = max(v, 1)
		experience_required = get_required_exp(level+1)
		calculate_stats()
		leveled_up.emit(v)
var experience : int
var experience_total : int = 0
var experience_required : int

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
	learn_moves(&"level_up", level)

#endregion

@export_category("Sprites")
# HACK: DEPRECIATED, DELETE AFTER COMBAT REWORK IS DONE
@export var battle_scene : PackedScene
@export var combat_sprite : PackedScene
@export var icon : Texture
@export var dex_color : Color = Color.WHITE
@export_subgroup("Moves")
## It is recommended to have multiple learnsets, such as a TM list and a level up list
@export var learnsets : Dictionary = {
	&"level_up" : {},
	&"tutored" : {},
	&"hidden" : {}
}
var learned_moves : Array[BaseMove] #Change to Array[Move] later

@export_category("Statistics")
var status_condition : StatusCondition = -1
@export var base_exp_worth : int = 0
@export var hp_base : float = 0.0
@export var atk_base : float = 0.0
@export var def_base : float = 0.0
@export var spAtk_base : float = 0.0
@export var spDef_base : float = 0.0
@export var spd_base : float = 0.0

## key = stat_id, value = EV value
@export var ev_yields : Dictionary = {}

## Stats as a dictionary will be responsible for holding EVs, IVs, and growth values

var stats : Dictionary = {}

## Initialization for randomizing IVs, nature and moves
func initialize():
	randomize()
	var d : Monster = self.duplicate()
	d.gender = randi_range(1, 2) if not genderless else 0
	d.pid = randi()
	
	#print_debug( "Gender threshold: " , str(d.pid).pad_zeros(32).right(8) )
	calculate_stats(d)
	return d

## Duplicates the resouce of a 'wild' monster, so it can be added to the player's roster
func acquire(new_nickname : String):
	var acquired_monster = await initialize()
	if new_nickname.length() > 0:
		acquired_monster.nickname = new_nickname
	
	acquired_monster.trainer_id = PlayerHandler.get_id()
	acquired_monster._secret_trainer_id = PlayerHandler.get_id(true)
	acquired_monster.original_trainer = PlayerHandler.get_trainer()
	acquired_monster.captured_status = Monster.TAMED
	#calculate_stats(acquired_monster)
	#acquired_monster.recalculate_stats(acquired_monster)
	
	#acquired_monster.level.leveled_up.connect(_on_level_up)
	#print_debug(acquired_monster.level.leveled_up.get_connections())
	return acquired_monster 

## Turns self into a JSON Dictionary
func serialize():
	return {
		"pid": pid,
		"nickname" : nickname,
		"OT": [trainer_id, _secret_trainer_id],
		"trainer_name" : original_trainer,
		"status_condition" : status_condition,
		"level" : level,
		"stats" : serialize_stats(),
		"data" : {
			"learned_moves" : serialize_moves(),
			"species" : id,
			"experience" : [experience, experience_required, experience_total],
			"friendship" : friendship
		}
	}

func deserialize( monster : Dictionary ):
	pid = monster.get("pid", null)
	if not pid:
		push_warning("Could not find PID, canceling deserialization.")
		return
	nickname = monster.get("nickname", monster.data.get("species") )
	id = monster.data.get("species", null)
	trainer_id = monster.get("OT")[0]
	_secret_trainer_id = monster.get("OT")[1]
	original_trainer = monster.get("trainer_name")
	level = monster.get("level", 1)
	status_condition = monster.get("status_condition", -1)

#region STAT MANIPULATION
func serialize_stats():
	var serialized : Array = []
	for s in stats.values():
		serialized.push_back( s.serialize() )
	return serialized

func get_stat(id : StringName):
	if id in stats.keys():
		return {
			&"self" : stats[id],
			&"value" : stats[id].value,
			&"max" : stats[id].max_value
		}
	return {}

func calculate_stats(monster : Monster = self):
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
		monster.stats[stat_id] = Stat.new(stat_id, base, monster, formula)
		#print(monster.stats[stat_id].value)

func decrease_stat(id, amount):
	if id in stats:
		stats[id].decrease(amount)

func increase_stat(id, amount):
	if id in stats:
		stats[id].increase(amount)
#endregion

#region Moves

func serialize_moves():
	var serial : Array
	for move : BaseMove in learned_moves:
		serial.push_back( move.serialize() )
	return serial

func learn_moves( learnset_key : StringName, move_key ):
	var learnset = learnsets.get(learnset_key, null)
	if not learnset: return
	
	var to_learn = learnset.get(move_key, null)
	if not to_learn: return
	
	#print_debug(to_learn)
	for move in to_learn:
		if not learned_moves.has(move):
			learned_moves.push_front(move.duplicate(true))
			print("%s learned %s!" % [nickname, move.name])
			#move_learned.emit(move)
	return

func get_battle_moves()->Array[BaseMove]:
	var first_four : Array[BaseMove]
	for move in learned_moves:
		if first_four.size() < 4:
			first_four.push_back(move)
	
	return first_four
#endregion

# EOF #
