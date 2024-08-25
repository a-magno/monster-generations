@tool
extends Node2D
class_name FloatingLabel

@export var enabled : bool = true
var text_queue : Array
var timer : Timer
@onready var label = %Label
@onready var animation_player = $AnimationPlayer

const FORMAT = "[center]{text}"
const DELAY_BETWEEN_RESETS = 1.0

func _ready():
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func _process(delta):
	if not enabled:
		return
	if text_queue.size() > 0 and timer.is_stopped() and not animation_player.is_playing():
		play_text()

## Allows BBCode
func play_text():
	timer.wait_time = DELAY_BETWEEN_RESETS
	while text_queue.size() > 0:
		show()
		label.text = FORMAT.format({"text" : text_queue.pop_front()})
		timer.start()
		await timer.timeout
		animation_player.play("popup")
		await animation_player.animation_finished
		animation_player.play("RESET")
		hide()

func queue_text( _text : String):
	text_queue.push_back(_text)
