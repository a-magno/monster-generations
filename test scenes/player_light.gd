extends PointLight2D

@export var has_light : bool = true

func _ready():
	WorldTime.time_tick.connect(_on_time_tick)
	enabled = false

func _on_time_tick(data):
	#scale.x *= sin(WorldTime.time * 1) * 1
	#scale.y *= sin(WorldTime.time * 1) * 1
	enabled = !data.hour in range( 4, 17 )
