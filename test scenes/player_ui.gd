extends CanvasLayer

@export var inventory: Control
@onready var player : Player = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remove_child(inventory)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("INVENTORY") :
		if not inventory.is_inside_tree() and not player.state == Player.States.BUSY:
			player.state = Player.States.BUSY
			add_child(inventory)
			inventory.open()
		else:
			player.state = Player.States.IDLE
			remove_child(inventory)
			inventory.close()
