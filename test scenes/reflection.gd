@tool
extends Sprite2D

@export var enabled : bool = true
@export var source : Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enabled or not source: return
	texture = source.texture
	hframes = source.hframes
	vframes = source.vframes
	frame = source.frame
