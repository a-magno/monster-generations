extends Actor
class_name Player

@onready var floating_label = %FloatingLabel

func _ready():
	animation_tree.active = true
	parent = get_parent()
	PlayerData.player_instance = self
	
func _physics_process(delta: float) -> void:
	#$PlayerUI/Label.text = "State: %s\nStepping on: %s" % [state, str(parent.is_stepping_on(position))]
	$PlayerUI/Label.text = str((position + ray.target_position))
	#var dir = get_player_input()
	#var target_position = Vector2(tile_size * dir)
	#looking_at = ray.target_position + position
	#
	#match(state):
		#IDLE:
			#if not target_position == Vector2.ZERO :
				#if parent.can_move_to(position + target_position) and ray_look_at(target_position):
					#move_to(target_position)
					##parent.check_encounter(target_position)
				#else:
					#turn_to(target_position)
		#
			#if Input.is_action_just_pressed("EXAMINE"):
				##FloatingText.position = position - Vector2(32, 64)
				#if await interact( looking_at ):
					#return
				#if await examine( looking_at ):
					#return
			#if Input.is_action_just_pressed("GRAB"):
				##FloatingText.position = position - Vector2(32, 64)
				#grab_items( looking_at )
		#BUSY:
			#pass
	##

func interact(target_position):
	var collider : Actor = ray.get_collider()
	if not collider: return false
	collider.face( (position - collider.position ).normalized() )
	var dialogue_node : DialoguePlayer = collider.find_child(&"Dialogue*")
	if dialogue_node:
		DialogueBox.show_dialogue(collider, dialogue_node)
		dialogue_node.dialogue_finished.connect(
			func(): state = IDLE
		)
		state = BUSY
	return dialogue_node

func examine(target_position):
	target_position += position
	print_debug(target_position)
	var response = parent.request_examine( target_position )
	floating_label.queue_text( response.dialogue )
	if response.get("contents", null):
		var item_count = response.contents.size()
		var txt : String = "Found {0}".format(["%d items here!" % item_count if item_count > 1 else "an item here!"])

		floating_label.queue_text( txt )
		return true
	return false
#
func grab_items(target_position):
	target_position += position
	var response = parent.loot_items(target_position)
	if response.success:
		for i in response.contents:
			if i is not Item:
				continue
			#print(i)
			PlayerData.add_item( i )
			var txt : String = "Picked up [color=cyan]%s[/color]!" % i.name
			#EventLog.log_text(txt)
			floating_label.queue_text( txt )
	else:
		floating_label.queue_text( response.contents )
