extends CanvasModulate

@export var gradient_texture:GradientTexture1D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var value = (sin( WorldTime.time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient_texture.gradient.sample(value)
