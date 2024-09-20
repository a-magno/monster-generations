extends Resource
class_name EvolutionData

## Meant to be inherited from

@export var target : MonsterCore

func evolve():
	if not can_evolve(): return

func can_evolve()->bool:
	return false
