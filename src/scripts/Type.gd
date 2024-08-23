extends Node

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
	{ 2.0: [Types.FIGHTING], 0.5: [], 0.0: [Types.GHOST] },
	
	# Fire
	{ 2.0: [Types.WATER, Types.GROUND, Types.ROCK], 0.5: [Types.FIRE], 0.0: [] },
	
	# Water
	{ 2.0: [Types.ELECTRIC, Types.GRASS], 0.5: [Types.FIRE, Types.WATER, Types.ICE, Types.STEEL], 0.0: [] },
	
	# Electric
	{ 2.0: [Types.GROUND], 0.5: [Types.ELECTRIC, Types.FLYING, Types.STEEL], 0.0: [Types.GROUND] },
	
	# Grass
	{ 2.0: [Types.FIRE, Types.FLYING, Types.BUG], 0.5: [Types.WATER, Types.GRASS, Types.ELECTRIC, Types.GROUND], 0.0: [] },
	
	# Ice
	{ 2.0: [Types.FIRE, Types.STEEL], 0.5: [Types.ICE, Types.WATER, Types.GRASS, Types.GROUND], 0.0: [] },
	
	# Fighting
	{ 2.0: [Types.FLYING, Types.PSYCHIC, Types.FAIRY], 0.5: [Types.BUG, Types.ROCK, Types.DARK], 0.0: [] },
	
	# Poison
	{ 2.0: [Types.GROUND, Types.PSYCHIC], 0.5: [Types.GRASS, Types.FIGHTING, Types.POISON, Types.BUG, Types.FAIRY], 0.0: [] },
	
	# Ground
	{ 2.0: [Types.WATER, Types.GRASS, Types.ICE], 0.5: [Types.POISON, Types.ROCK, Types.ELECTRIC], 0.0: [Types.ELECTRIC] },
	
	# Flying
	{ 2.0: [Types.ELECTRIC, Types.ICE, Types.ROCK], 0.5: [Types.GRASS, Types.FIGHTING, Types.BUG], 0.0: [] },
	
	# Psychic
	{ 2.0: [Types.BUG, Types.GHOST, Types.DARK], 0.5: [Types.FIGHTING, Types.PSYCHIC], 0.0: [] },
	
	# Bug
	{ 2.0: [Types.FIRE, Types.FLYING, Types.ROCK], 0.5: [Types.GRASS, Types.FIGHTING, Types.GROUND, Types.BUG], 0.0: [] },
	
	# Rock
	{ 2.0: [Types.WATER, Types.GRASS, Types.FIGHTING, Types.STEEL], 0.5: [Types.NORMAL, Types.FIRE, Types.POISON, Types.FLYING], 0.0: [] },
	
	# Ghost
	{ 2.0: [Types.GHOST, Types.DARK], 0.5: [Types.POISON, Types.BUG], 0.0: [Types.NORMAL, Types.FIGHTING] },
	
	# Dragon
	{ 2.0: [Types.ICE, Types.DRAGON, Types.FAIRY], 0.5: [Types.FIRE, Types.WATER, Types.ELECTRIC, Types.GRASS], 0.0: [] },
	
	# Dark
	{ 2.0: [Types.FIGHTING, Types.BUG, Types.FAIRY], 0.5: [Types.GHOST, Types.DARK], 0.0: [] },
	
	# Steel
	{ 2.0: [Types.FIRE, Types.FIGHTING, Types.GROUND], 0.5: [Types.NORMAL, Types.GRASS, Types.ICE, Types.FLYING, Types.PSYCHIC, Types.BUG, Types.ROCK, Types.DRAGON, Types.STEEL, Types.FAIRY], 0.0: [] },
	
	# Fairy
	{ 2.0: [Types.POISON, Types.STEEL], 0.5: [Types.FIGHTING, Types.BUG, Types.DARK], 0.0: [] }
]
