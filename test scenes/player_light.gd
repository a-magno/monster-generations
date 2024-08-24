extends PointLight2D

@export var has_light : bool = true
@export var flickering := true
func _ready():
	WorldTime.time_tick.connect(_on_time_tick)
	enabled = false
	flicker()

func _on_time_tick(data):
	#scale.x *= sin(WorldTime.time * 1) * 1
	#scale.y *= sin(WorldTime.time * 1) * 1
	var turn_on = !data.hour in range( 4, 17 )
	var t = create_tween()
	if not turn_on:
		t.tween_property(self, "energy", 0.0, 0.2)
		await t.finished
	else:
		t.tween_property(self, "energy", 0.6, 0.2)
	await t.finished
	enabled = turn_on

func flicker():
	if flickering:
		var t = create_tween()
		t.finished.connect(
			func():
				flicker()
		)
		t.tween_property(self, "scale", Vector2(2.2, 2.2), 0.2)
		t.chain().tween_property(self, "scale", Vector2(2.5, 2.5), 0.2)
