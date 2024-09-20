extends ProgressBar

func set_data( data : Monster ):
	initialize( data.experience, data.experience_required )
	data.gained_exp.connect(_on_exp_gained)

func initialize(curr, max):
	max_value = max
	value = curr
	
func _on_exp_gained( data ):
	for line in data:
		var target_exp = line[0]
		var max_exp = line[1]
		max_value = max_exp
		await animate_bar(target_exp)
		if is_equal_approx(max_value, value):
			value = min_value
	CombatEvent.exp_updated.emit()

func animate_bar(target, duration := 1.0):
	var tween = create_tween()
	tween.tween_property(self, "value", target, duration)
	await tween.finished

#region TEST
func _on_leveled_up(new_level: Variant) -> void:
	$Label.text = "Lv. %3d" % (new_level)
#endregion
