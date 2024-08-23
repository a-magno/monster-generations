extends Node2D

const WildAi = preload("res://src/scripts/wild_ai.gd")

signal battle_over(winner, loser)

@export var test_fighters : Array[Monster]

@onready var combatants: Node2D = $Combatants
@onready var battle_ui: Control = $"Battle UI"
@onready var turn_queue: Node = $TurnQueue

#func _ready():
	#var fighters = test_fighters # debug
	#start_battle(fighters)

func start_battle( fighters ):

	for data : Monster in fighters:
		if not data.is_instance:
			data = data.initialize()
		var combatant = data.battle_scene.instantiate() as Combatant
		combatant.set_data( data )
		if data.captured_status == Monster.TAMED:
			combatant.name = "Player"
			#print_debug("Player monster level: %d" % data.level)
		else:
			var ai = WildAi.new()
			ai.combatant = combatant
			ai.list = combatants
			combatant.add_child(ai)
			combatant.turn_start.connect(ai.act)
			var timer = Timer.new()
			timer.wait_time = 0.25
			timer.one_shot = true
			combatant.add_child(timer)
			ai.timer = timer
			
		combatants.add_combatant(combatant)
		combatant.health.dead.connect(_on_combatant_death)
	battle_ui.start()
	turn_queue.start()

func clear_combat():
	for n in combatants.get_children():
		if n is Combatant:
			n.queue_free()
		combatants.combatants.clear()
	battle_ui.free_info_nodes()


func finish_combat(winner, loser):
	battle_over.emit(winner, loser)


func _on_combatant_death(combatant):
	var winner
	if not combatant.name == "Player":
		winner = combatants.get_node("Player")
	else:
		for n in combatants.get_children():
			if not n.name == "Player":
				winner = n
				break
	finish_combat(winner, combatant)
