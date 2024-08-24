extends Control

signal get_next_line

var dialogue_node 
@onready var speaker_name = $PanelContainer/MarginContainer/Name
@onready var text_input = $PanelContainer2/MarginContainer/Text

func _ready():
	hide()

func _process(delta):
	if Input.is_action_just_released("EXAMINE"):
		get_next_line.emit()

func show_dialogue(speaker : String, dialogue : String):
	show()
	grab_focus()
	dialogue_node = dialogue
	#for c in dialogue.get_signal_connection_list("dialogue_started"):
		#if player == c.callable.get_object():
			#dialogue_node.start_dialogue()
			#speaker_name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
			#text_input.text = dialogue_node.dialogue_text
			#return
	#dialogue_node.dialogue_started.connect(player.set_active.bind(false))
	#dialogue_node.dialogue_finished.connect(player.set_active.bind(true))
	#dialogue_node.dialogue_finished.connect(hide)
	#dialogue_node.dialogue_finished.connect(_on_dialogue_finished.bind(player))
	dialogue_node.start_dialogue()
	speaker_name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
	text_input.text = dialogue_node.dialogue_text

func _on_get_next_dialogue():
	dialogue_node.next_dialogue()
	speaker_name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
	text_input.text = dialogue_node.dialogue_text


func _on_dialogue_finished(player):
	dialogue_node.dialogue_started.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(player.set_active)
	dialogue_node.dialogue_finished.disconnect(hide)
	dialogue_node.dialogue_finished.disconnect(_on_dialogue_finished)
