extends CharacterBody2D
class_name Player

@onready var ray: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite
@onready var animation_tree: AnimationTree = $AnimationTree

#testing
@onready var label = $PlayerUI/Label
@export var precise_timekeeping := true
@onready var daytime = WorldTime.TimeOfDay.get(WorldTime.INITIAL_HOUR)

var parent : Node2D
enum States { IDLE, MOVING, BATTLING, BUSY }
var state : States = States.IDLE
var tween
var looking_at : Vector2
var tile_size := Vector2i(64, 64)

func _ready():
	animation_tree.active = true
	parent = get_parent()
	PlayerData.player_instance = self
	WorldTime.time_tick.connect(
		func(data):
			label.text = ""
			if precise_timekeeping:
				label.text = "Day %0*d - %0*d : %0*d" % [2, data.day, 2, data.hour, 2, data.minute]
			else:
				daytime = WorldTime.TimeOfDay.get(data.hour, daytime)
				label.text = "%s" % daytime
	)

func _physics_process(delta: float) -> void:
	
	var dir = get_player_input()
	var target_position = Vector2(tile_size * dir)
	looking_at = ray.target_position + position
	
	match(state):
		States.IDLE:
			FloatingText.position = position - Vector2(32, 64)
			if not target_position == Vector2.ZERO :
				if parent.can_move_to(position + target_position) and ray_look_at(target_position):
					move_to(target_position)
					#parent.check_encounter(target_position)
				else:
					turn_to(target_position)
		
			if Input.is_action_just_pressed("EXAMINE"):
				FloatingText.position = position - Vector2(32, 64)
				examine( looking_at )
			if Input.is_action_just_pressed("GRAB"):
				FloatingText.position = position - Vector2(32, 64)
				grab_items( looking_at )
		States.BUSY:
			pass
	#"State: %s\nStepping on: %s" % [States.keys()[state], str(parent.is_stepping_on(position))]

func move_to(target_position):
	if state == States.MOVING: return
	if target_position == Vector2.ZERO: return
	if !ray_look_at(target_position):
		turn_to(target_position)
		return
	state = States.MOVING
	handle_animation(target_position.normalized())
	
	tween = create_tween()
	tween.tween_property(sprite, "position", target_position, 0.2).as_relative().from_current()
	await tween.finished
	position += target_position.snapped(Vector2(tile_size))
	
	PlayerData.world_pos = position
	sprite.position = Vector2.ZERO
	tween = null
	looking_at = target_position.normalized()
	state = States.IDLE
	
	if parent.is_stepping_on(position) == "tall_grass" and parent.check_encounter(position):
		print("Trigger Encounter")

func get_player_input()->Vector2i:
	if Input.is_action_pressed("LEFT"):
		ray.target_position = Vector2i.LEFT * tile_size
		return Vector2i.LEFT
	if Input.is_action_pressed("RIGHT"):
		ray.target_position = Vector2i.RIGHT * tile_size
		return Vector2i.RIGHT
	if Input.is_action_pressed("UP"):
		ray.target_position = Vector2i.UP * tile_size
		return Vector2i.UP
	if Input.is_action_pressed("DOWN"):
		ray.target_position = Vector2i.DOWN * tile_size
		return Vector2i.DOWN
	return Vector2i.ZERO

func handle_animation(dir):
	animation_tree["parameters/idle/blend_position"] = dir
	animation_tree["parameters/walk/blend_position"] = dir
	
func ray_look_at(target_pos):
	ray.target_position = target_pos
	return !ray.is_colliding()
	
func turn_to( towards ):
	#ray.target_position = looking_at
	animation_tree["parameters/idle/blend_position"] = towards.normalized()
	animation_tree["parameters/walk/blend_position"] = towards.normalized()

func examine(target_position):
	var response = parent.request_examine( target_position )
	#FloatingText.init_pos = position - Vector2(32, 64)
	await FloatingText.display_text(response.dialogue, 0.5)
	FloatingText._reset()
	
	if response.get("contents", null):
		#FloatingText.position = position - Vector2(32, 64)
		
		var item_count = response.contents.size()
		var txt : String = "Found {0}".format(["%d items here!" % item_count if item_count > 1 else "an item here!"])

		await FloatingText.display_text( txt, 0.5)

func grab_items(target_position):
	var response = parent.request_items(target_position)
	
	if response.success:
		for i in response.contents:
			if i is not Item:
				continue
			#print(i)
			PlayerData.add_item( i )
			var txt : String = "Picked up [color=cyan]%s[/color]!" % i.name
			await FloatingText.display_text( txt, 0.5)
			
