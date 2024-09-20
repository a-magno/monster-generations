extends GridContainer

@export var _test_moves : Array[BaseMove]

const BUTTON = preload("res://src/scenes/ui/move select/option/button.tscn")

func _ready():
	hide()

func activate():
	populate_with_moves( _test_moves )
	show()
	#grab_focus()

func populate_with_moves( moves : Array[BaseMove]):
	for c in get_children():
		c.queue_free()

	for move in moves:
		var btn = BUTTON.instantiate()
		btn.set_data(move)
		add_child(btn)
		btn.pressed.connect( move_chosen.bind( move ) )

func move_chosen( move : BaseMove ):
	CombatEvent.ui_move_selected.emit(move)
	#release_focus()
