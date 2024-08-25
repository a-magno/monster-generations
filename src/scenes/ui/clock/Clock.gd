extends Control

@onready var label = $Label
var precise_timekeeping := false
var daytime = WorldTime.TimeOfDay.get(WorldTime.INITIAL_HOUR)

func _ready():
	WorldTime.time_tick.connect(
		func(data):
			label.text = ""
			if precise_timekeeping:
				label.text = "Day %0*d - %0*d : %0*d" % [2, data.day, 2, data.hour, 2, data.minute]
			else:
				daytime = WorldTime.TimeOfDay.get(data.hour, daytime)
				label.text = "Day %3d - %s" % [data.day, daytime]
	)
