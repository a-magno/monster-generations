extends Node
const WEAKNESS = 2.0
const RESISTANCE = 0.5
const IMMUNITY = 0.0

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
var type_matchups : Array = [
	# Normal
	{ WEAKNESS: [Types.FIGHTING], RESISTANCE: [], IMMUNITY: [Types.GHOST] },
	
	# Fire
	{ WEAKNESS: [Types.WATER, Types.GROUND, Types.ROCK], RESISTANCE: [Types.FIRE], IMMUNITY: [] },
	
	# Water
	{ WEAKNESS: [Types.ELECTRIC, Types.GRASS], RESISTANCE: [Types.FIRE, Types.WATER, Types.ICE, Types.STEEL], IMMUNITY: [] },
	
	# Electric
	{ WEAKNESS: [Types.GROUND], RESISTANCE: [Types.ELECTRIC, Types.FLYING, Types.STEEL], IMMUNITY: [Types.GROUND] },
	
	# Grass
	{ WEAKNESS: [Types.FIRE, Types.FLYING, Types.BUG], RESISTANCE: [Types.WATER, Types.GRASS, Types.ELECTRIC, Types.GROUND], IMMUNITY: [] },
	
	# Ice
	{ WEAKNESS: [Types.FIRE, Types.STEEL], RESISTANCE: [Types.ICE, Types.WATER, Types.GRASS, Types.GROUND], IMMUNITY: [] },
	
	# Fighting
	{ WEAKNESS: [Types.FLYING, Types.PSYCHIC, Types.FAIRY], RESISTANCE: [Types.BUG, Types.ROCK, Types.DARK], IMMUNITY: [] },
	
	# Poison
	{ WEAKNESS: [Types.GROUND, Types.PSYCHIC], RESISTANCE: [Types.GRASS, Types.FIGHTING, Types.POISON, Types.BUG, Types.FAIRY], IMMUNITY: [] },
	
	# Ground
	{ WEAKNESS: [Types.WATER, Types.GRASS, Types.ICE], RESISTANCE: [Types.POISON, Types.ROCK, Types.ELECTRIC], IMMUNITY: [Types.ELECTRIC] },
	
	# Flying
	{ WEAKNESS: [Types.ELECTRIC, Types.ICE, Types.ROCK], RESISTANCE: [Types.GRASS, Types.FIGHTING, Types.BUG], IMMUNITY: [] },
	
	# Psychic
	{ WEAKNESS: [Types.BUG, Types.GHOST, Types.DARK], RESISTANCE: [Types.FIGHTING, Types.PSYCHIC], IMMUNITY: [] },
	
	# Bug
	{ WEAKNESS: [Types.FIRE, Types.FLYING, Types.ROCK], RESISTANCE: [Types.GRASS, Types.FIGHTING, Types.GROUND, Types.BUG], IMMUNITY: [] },
	
	# Rock
	{ WEAKNESS: [Types.WATER, Types.GRASS, Types.FIGHTING, Types.STEEL], RESISTANCE: [Types.NORMAL, Types.FIRE, Types.POISON, Types.FLYING], IMMUNITY: [] },
	
	# Ghost
	{ WEAKNESS: [Types.GHOST, Types.DARK], RESISTANCE: [Types.POISON, Types.BUG], IMMUNITY: [Types.NORMAL, Types.FIGHTING] },
	
	# Dragon
	{ WEAKNESS: [Types.ICE, Types.DRAGON, Types.FAIRY], RESISTANCE: [Types.FIRE, Types.WATER, Types.ELECTRIC, Types.GRASS], IMMUNITY: [] },
	
	# Dark
	{ WEAKNESS: [Types.FIGHTING, Types.BUG, Types.FAIRY], RESISTANCE: [Types.GHOST, Types.DARK], IMMUNITY: [] },
	
	# Steel
	{ WEAKNESS: [Types.FIRE, Types.FIGHTING, Types.GROUND], RESISTANCE: [Types.NORMAL, Types.GRASS, Types.ICE, Types.FLYING, Types.PSYCHIC, Types.BUG, Types.ROCK, Types.DRAGON, Types.STEEL, Types.FAIRY], IMMUNITY: [] },
	
	# Fairy
	{ WEAKNESS: [Types.POISON, Types.STEEL], RESISTANCE: [Types.FIGHTING, Types.BUG, Types.DARK], IMMUNITY: [] }
]

func matchup( def_type : Types, atk_type : Types ):
	if atk_type in type_matchups[def_type].get(WEAKNESS, null):
		return WEAKNESS
	if atk_type in type_matchups[def_type].get(RESISTANCE, null):
		return RESISTANCE
	if atk_type in type_matchups[def_type].get(IMMUNITY, null):
		return IMMUNITY
	return 1.0

func as_string( type : Types ):
	return Types.keys()[type]
