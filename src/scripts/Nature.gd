extends Resource
class_name Nature

enum StatToModify {HP, ATTACK, DEFENSE, SPECIAL_ATTACK, SPECIAL_DEFENSE, SPEED}
var enumToDict : Dictionary = {
	"hp": StatToModify.HP,
	"atk": StatToModify.ATTACK,
	"def": StatToModify.DEFENSE,
	"spAtk": StatToModify.SPECIAL_ATTACK,
	"spDef": StatToModify.SPECIAL_DEFENSE,
	"spd": StatToModify.SPEED,
	}
@export var NATURE_NAME : String
@export var STAT_UP : StatToModify
@export var STAT_DOWN : StatToModify

func get_mod(stat_id : StringName):
	return get_modifier( enumToDict.get(stat_id, -1) )

func get_modifier(stat_index) -> float:
	if stat_index == STAT_UP:
		return 0.1
	if stat_index == STAT_DOWN:
		return -0.1
	return 0.0
