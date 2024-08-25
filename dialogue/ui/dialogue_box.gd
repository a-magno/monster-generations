extends CanvasLayer

signal get_next_line

var dialogue_node : DialoguePlayer = null
@onready var speaker_name = $PanelContainer/MarginContainer/Name
@onready var text_input = $PanelContainer2/MarginContainer/Text

func _ready():
	hide()
	get_next_line.connect(_on_get_next_dialogue)

func _process(delta):
	if Input.is_action_just_pressed("EXAMINE"):
		if not dialogue_node:
			return
		if dialogue_node.dialogue_finished.is_connected(_on_dialogue_finished):
			get_next_line.emit()

func show_dialogue(speaker, dialogue : DialoguePlayer):
	show()
	text_input.grab_focus()
	dialogue_node = dialogue
	for c in dialogue.get_signal_connection_list("dialogue_started"):
		if speaker == c.callable.get_object():
			dialogue_node.start_dialogue()
			speaker_name.text = "[center]" + dialogue_node.dialogue_name + "[/center]"
			text_input.text = dialogue_node.dialogue_text
			return
	dialogue_node.dialogue_started.connect(speaker.set_active.bind(false))
	dialogue_node.dialogue_finished.connect(speaker.set_active.bind(true))
	dialogue_node.dialogue_finished.connect(hide)
	dialogue_node.dialogue_finished.connect(_on_dialogue_finished.bind(speaker))
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
