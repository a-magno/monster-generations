extends Node

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

signal time_tick( data : Dictionary )

var gradient_texture = preload("res://src/scripts/day-night-cycle/daynightcycle-gradient-texture.tres")

# TODO: Expose in game settings later
#var INGAME_SPEED = 20.0
var INGAME_SPEED = 70.0
var INITIAL_HOUR = 5:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR

var time:float= 0.0
var past_minute:int= -1
var paused := false
const TimeOfDay : Dictionary = {
	0 : "MIDNIGHT",
	4 : "DAWN",
	8 : "MORNING",
	12 : "NOON",
	13 : "AFTERNOON",
	18 : "DUSK",
	19 : "EVENING"
}

func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR

func _process(delta: float) -> void:
	if paused:
		return
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	
	_recalculate_time()

func _recalculate_time() -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	
	var day = int(total_minutes / MINUTES_PER_DAY)

	var current_day_minutes = total_minutes % MINUTES_PER_DAY

	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if past_minute != minute:
		past_minute = minute
		var data = {
			"day" : day,
			"hour" : hour,
			"minute" : minute
		}
		time_tick.emit(data)

func pause( toggle := true ):
	paused = toggle
