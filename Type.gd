extends Resource
class_name Type

enum Types {
	NULL,
	NORMAL,
	FIRE,
	WATER,
	ELECTRIC,
	GRASS,
	ICE,
	FIGHTING,
	POISON,
	GROUND,
	FLYING,
	PSYCHIC,
	BUG,
	ROCK,
	GHOST,
	DRAGON,
	DARK,
	STEEL,
	FAIRY
}

@export var value : Types
@export var weaknesses : Array[Types]
@export var immunities : Array[Types]
@export var resistances : Array[Types]

func matchup( atk_type : Types ):
	if atk_type in weaknesses:
		return 2.0
	if atk_type in resistances:
		return 0.5
	if atk_type in immunities:
		return 0.0
	return 1.0
func as_string(type := value):
	return Types.keys()[type]
