extends Control

signal monster_selected( m : Monster )

enum Mode {SELECT, MANAGE}
var is_open : bool = false
const MONSTER_SLOT = preload("res://src/scenes/ui/party list/monster_slot.tscn")
@onready var team_list = %TeamList

func _ready():
	close()

func _process(delta):
	if Input.is_action_just_pressed("PARTY"):
		if not is_open:
			open()
		else:
			close()
		is_open = !is_open

func open( mode : Mode = Mode.MANAGE):
	_fill_party_list()
	activate()
	PlayerData.set_player_state( Actor.BUSY )

func close():
	hide()
	release_focus()
	PlayerData.set_player_state( Actor.IDLE )

func _fill_party_list():
	for c in team_list.get_children():
		c.queue_free()
	for monster in PlayerData.party:
		var slot = MONSTER_SLOT.instantiate()
		team_list.add_child(slot)
		slot.set_data( monster )

func activate():
	show()
	grab_focus()
	
