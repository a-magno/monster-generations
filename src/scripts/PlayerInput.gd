extends Node2D
class_name PlayerInput

signal player_moved
@export var enabled := true
@export var player : Actor
var last_direction := Vector2.ZERO

func _physics_process(delta):
	if not enabled: return
	if player.state == Player.IDLE:
		
		var facing = get_player_input()
		player.face( facing if facing != Vector2.ZERO else last_direction )
	
		if not facing == Vector2.ZERO :
			if player.request_move( facing ):
				player.move( facing )
			last_direction = facing
		if Input.is_action_just_pressed("EXAMINE"):
			if await player.interact( position + player.ray.target_position ):
					return
			if await player.examine( position + player.ray.target_position ):
				return
		if Input.is_action_just_pressed("GRAB"):
			player.grab_items( position + player.ray.target_position )
	if player.state == Player.MOVING:
		pass

func get_player_input()->Vector2:
	if Input.is_action_pressed("LEFT"):
		return Vector2.LEFT
	if Input.is_action_pressed("RIGHT"):
		return Vector2.RIGHT
	if Input.is_action_pressed("UP"):
		return Vector2.UP
	if Input.is_action_pressed("DOWN"):
		return Vector2.DOWN
	return Vector2.ZERO
