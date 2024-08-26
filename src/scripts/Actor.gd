extends CharacterBody2D
class_name Actor

enum {IDLE, MOVING, BATTLING, BUSY}

@export var looking_at : Vector2 = Vector2.DOWN
@export var sprite : Sprite2D
@export var ray : RayCast2D
@export var animation_tree : AnimationTree
@onready var parent : Node2D = get_parent()
var tile_size := Vector2( 64, 64 )
var active = true: set = set_active
var state = IDLE

func set_active(value):
	active = value
	set_process(value)
	set_process_input(value)

## Points [class RayCast2D] towards a tile in a given [param direction]
func face( direction : Vector2 ):
	looking_at = tile_size * direction
	if ray:
		ray.target_position = looking_at
		ray.force_raycast_update()
	animation_tree["parameters/idle/blend_position"] = looking_at.normalized()
	animation_tree["parameters/walk/blend_position"] = looking_at.normalized()

var tween
func move( target_position ):
	if state == MOVING: return
	if target_position == Vector2.ZERO: return
	
	state = MOVING
	target_position *= tile_size
	
	## Points ray in direction of the movement for actor checking
	ray.target_position = target_position
	if ray.is_colliding(): 
		state = IDLE
		return # returns in case there's an entity there
	tween = create_tween()
	tween.tween_property(sprite, "position", target_position, 0.2).as_relative().from_current()
	await tween.finished
	position += target_position.snapped(Vector2(tile_size))
	sprite.position = Vector2.ZERO
	tween = null
	state = IDLE
	
	parent.check_encounter(position)

## Asks parent if movement is possible
func request_move( towards ):
	return parent.request_move( position + towards * tile_size )
