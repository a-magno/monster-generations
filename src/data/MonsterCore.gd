extends DataCore
class_name MonsterCore

# https://bulbapedia.bulbagarden.net/wiki/Pokémon_Evolution_data_structure_(Generation_IV)
const CoreStats = {
	&"hp": {"formula": "( (IV + 2 * base + (EV/4) ) * level/100 ) + 10 + level"},
	&"atk" : {},
	&"def" : {},
	&"spd" : {},
	&"spAtk" : {},
	&"spDef" : {},
	}

enum EggGroup {
	MONSTER, BUG, FLYING, FIELD,
	GRASS, HUMANOID, MINERAL,
	AMORPHOUS, DRAGON, UNKNOWN
}

@export var id : StringName
@export_range(0, 255, 1) var gender_threshold = 255

@export var type1 : Typing.Types
@export var type2 : Typing.Types

@export var base_hp : int
@export var base_atk : int
@export var base_def : int
@export var base_spd : int
@export var base_spAtk : int
@export var base_spDef : int

@export var growth_type : Level.GrowthTypes = Level.GrowthTypes.FAST
@export var catch_rate : float
@export var base_exp_yield : int

@export var egg_cycle : int
@export var group1 : EggGroup
@export var group2 : EggGroup

@export var ability1 : Ability
@export var ability2 : Ability
@export var ability_hidden : Ability

@export var learnset : Dictionary = {
	&"level": {}
}
# If both Item 1 and Item 2 are the same, then the Monster will always be holding that item when it is encountered.
@export var items : Dictionary = {
	0.5 : null,
	0.05 : null
}

@export var evolves_into : EvolutionData

func serialize():
	var data : Dictionary = {}

func deserialize( data : Dictionary ): pass
