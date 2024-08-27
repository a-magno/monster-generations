extends Node

# Dictionary to store loaded monster resources
var monsters : Dictionary = {}

# Path to the folder containing monster resources
const monster_folder : String = "res://src/monsters/"

# Called when the node is added to the scene for the first time
func _ready():
	load_all_monsters()

# Loads all monster resources from the specified folder
func load_all_monsters() -> void:
	var dir = DirAccess.open(monster_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var monster_path = monster_folder + file_name
				var monster_resource = load(monster_path)
				if monster_resource and monster_resource is Monster:
					monsters[monster_resource.id] = monster_resource
					print("Loaded monster: %s" % monster_resource.id)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error: Unable to open monster folder: %s" % monster_folder)

# Unloads a specific monster by ID
func unload_monster(monster_id : StringName) -> void:
	if monster_id in monsters:
		monsters.erase(monster_id)
		print("Unloaded monster: %s" % monster_id)
	else:
		print("Error: Monster with ID '%s' not found." % monster_id)

func generate_random_wild_monster():
	randomize()
	var monster_id = monsters.keys().pick_random()
	return generate_wild_monster(monster_id)

# Generates a wild monster by duplicating one of the loaded monsters
func generate_wild_monster(monster_id : StringName) -> Monster:
	if monster_id in monsters:
		var wild_monster = monsters[monster_id].duplicate()
		wild_monster.initialize() # Ensure the monster is initialized
		print("Generated wild monster: %s" % wild_monster.nickname)
		return wild_monster
	else:
		print("Error: Monster with ID '%s' not found." % monster_id)
		return null

# Generates a tamed monster, ready to be added to the player's party
func generate_tamed_monster(monster_id : StringName, nickname: String = "", level: int = 1) -> Monster:
	if monster_id in monsters:
		var tamed_monster : Monster = monsters[monster_id].duplicate()
		var _nickname = nickname if nickname != "" else monster_id.capitalize()
		tamed_monster = tamed_monster.acquire(_nickname) # Ensure the monster is initialized
		
		if level > 1:
			while tamed_monster.get_level() in range(level):
				tamed_monster.level.gain_exp( tamed_monster.level.exp_cap+1, tamed_monster )
				tamed_monster.level.leveled_up

		# Assume some taming process is handled here
		tamed_monster.captured_status = Monster.TAMED
		tamed_monster.captured_by = PlayerData.player_name  # Assign the monster to the player
		print("Generated tamed monster: %s at level %d" % [tamed_monster.nickname, tamed_monster.get_level()])

		return tamed_monster
	else:
		print("Error: Monster with ID '%s' not found." % monster_id)
		return null

# Unloads all monsters to free up resources
func unload_all_monsters() -> void:
	monsters.clear()
	print("Unloaded all monsters")
