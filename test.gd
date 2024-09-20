extends Node

@export var monster : MonsterData

func _ready():
	if monster:
		monster = monster.initialize()
		print(MonsterData.Gender.keys()[monster.gender])
