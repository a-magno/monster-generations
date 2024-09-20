extends PanelContainer

@onready var name_lbl = %Name
@onready var level_lbl = %Level
@onready var health_bar = %"Health Bar"
@onready var xp_bar = %"XP Bar"
@export var show_xp_bar : bool = true:
	set(v):
		show_xp_bar = v
		xp_bar.visible = show_xp_bar

var combatant : CombatantMonster

func set_data( _combatant : CombatantMonster ):
	combatant = _combatant
	name_lbl.text = combatant.monster_data.nickname
	
	level_lbl.text = "Lv. %3d" % combatant.monster_data.level
	#Update level display upon level-up mid battle
	combatant.monster_data.leveled_up.connect(_on_level_up)
	
	health_bar.initialize( combatant.health )
	xp_bar.set_data( combatant.monster_data )
	
	toggle_player_mode()

func _on_level_up( lvl ):
	level_lbl.text = "Lv. %3d" % lvl

func toggle_player_mode():
	if not combatant.monster_data.captured_status == Monster.TAMED:
		_flip_corners()
		show_xp_bar = false
		health_bar.display_number = false
		size_flags_horizontal = SIZE_EXPAND * SIZE_SHRINK_END
		

func _flip_corners():
	var sbox = get_theme_stylebox("panel") as StyleBoxFlat
	sbox.corner_radius_top_right = sbox.corner_radius_top_left
	sbox.corner_radius_bottom_left = sbox.corner_radius_bottom_right
	sbox.corner_radius_top_left = 0
	sbox.corner_radius_bottom_right = 0
	add_theme_stylebox_override("panel", sbox)
