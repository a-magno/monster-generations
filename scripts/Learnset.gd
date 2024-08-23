extends Resource
class_name Learnset

## keys are levels learned, values will be move to learn
@export var list : Dictionary = {}

func learn_move(level : int):
	return list.get(level, null)
