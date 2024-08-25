@tool
extends Sprite2D

@export var enabled : bool = true
var original_sprite
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	original_sprite = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enabled: return
	texture = original_sprite.texture
	hframes = original_sprite.hframes
	vframes = original_sprite.vframes
	frame = original_sprite.frame
