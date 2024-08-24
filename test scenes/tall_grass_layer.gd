extends TileMapLayer

func check_encounter(target_position):
	var target_cell = local_to_map(target_position)
	var cell_data = get_cell_tile_data(target_cell)

	if not cell_data: return null
	
	var chance = cell_data.get_custom_data("encounter_rate")
	if cell_data.get_custom_data("encounter_rate"):
		
		#encounter_triggered.emit( target_cell )
		if _roll_encounter(chance):
			var wild_one : Monster = MonsterManager.generate_random_wild_monster()
			get_parent().encounter_triggered.emit( wild_one )
	
func _roll_encounter(encounter_chance):
	randomize()
	return randf_range(0, 1) > encounter_chance
