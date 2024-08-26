extends Resource
class_name Learnset

## keys are levels or tm/hm ids to learned from, values will be move to learn
@export var id : StringName
@export var list : Dictionary = {}

func learn_move(target : Monster, key):
	var moves = list.get(key, null)
	if not moves: return
	for move in moves:
		target.learned_moves.push_front(move)
