extends Combatant
class_name Opponent

const WildAi = preload("res://src/scripts/wild_ai.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var ai = WildAi.new()
	ai.combatant = self
	#var timer = Timer.new()
	#timer.one_shot = true
	#timer.wait_time = 0.25
	add_child(ai)
	#add_child(timer)
