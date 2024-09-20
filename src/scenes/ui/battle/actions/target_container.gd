extends GridContainer

func populate_with_targets( group_name : StringName ):
	for c in get_children():
		c.queue_free()
	var valid_targets = get_tree().get_nodes_in_group(group_name)
	for t in valid_targets:
		var btn = Button.new()
		add_child(btn)
		btn.text = t.name
		btn.pressed.connect( _target_selected.bind( t ) )

func _target_selected( target : CombatantMonster ):
	CombatEvent.ui_target_selected.emit( target )
	hide()

func _on_tree_entered():
	CombatEvent.ui_move_selected.connect(
		func(move):
			populate_with_targets(CombatantMonster.OPPONENT_GROUP)
			show()
			#get_children().front().grab_focus()
	)
