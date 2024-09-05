extends GridContainer

const BUTTON = preload("res://src/scenes/ui/move select/option/button.tscn")

func _ready():
	hide()

func populate_with_moves( moves : Array[BaseMove]):
	for move in moves:
		var btn = BUTTON.instantiate()
		btn.set_data(move)
	show()
