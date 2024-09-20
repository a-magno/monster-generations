extends GridContainer

@export var move_container : Control  : 
	set(m):
		move_container = m

func activate():
	show()
	grab_focus()

func _on_fight_pressed() -> void:
	move_container.activate()
	hide()
