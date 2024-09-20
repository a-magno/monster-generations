extends Control

@onready var popup_panel = %PopupPanel
@onready var popup_message = %PopupMessage

func _ready():
	Event.file_save_sucessful.connect(_on_save_successful)

func _on_save_successful():
	popup_message.text = "Game saved successfully!"
	popup_panel.show()
	await get_tree().create_timer(1).timeout
	popup_panel.hide()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if not visible:
				show()
				$PanelContainer/MarginContainer/VBoxContainer/Save.grab_focus()
				Event.menu_opened.emit()
			else:
				hide()
				Event.menu_closed.emit()
	
func _on_save_pressed():
	$PanelContainer/MarginContainer/VBoxContainer/Save.release_focus()
	SaveManager.save_game()

func _on_quit_pressed():
	get_tree().quit()

func _on_tree_entered():
	hide()
