extends PanelContainer

signal updated( combatant )

@export var hp_gradient : Gradient
@export var hp_bg_gradient : Gradient
@onready var monster_name: Label = %Name
@onready var level_lbl: Label = %Level
@onready var healthbar: ProgressBar = %Healthbar
@onready var health_display: Label = %"Health Display"
@onready var exp_bar: ProgressBar = %ExpBar
@onready var gender_icon = %Gender
@onready var health_node : Health :
	set(h):
		health_node = h
@onready var data : Monster : set = set_data

var combatant : Combatant : set = set_combatant
var hp_style : StyleBoxFlat
var hp_bg : StyleBoxFlat
var tween
const HP_DISPLAY = "%d / %d"
const LVL_DISPLAY = "Lv. %d"

func _process(delta):
	if not tween:
		return
	health_display.text = "%d / %d" % [health_node.value, health_node.max_value]

func set_combatant( c : Combatant ):
	set_data( c.data )
	set_health_node( c.health )

func set_data( _data : Monster ):
	data = _data
	monster_name.text = data.nickname
	gender_icon.texture.region.size.x = 0 if data.gender == Monster.Gender.FEMALE else 16
	if data.captured_status == Monster.TAMED:
		$SkewNode.skew = deg_to_rad( 7.5 )
		exp_bar.show()
		data.leveled_up.connect(update)
	else:
		$SkewNode.skew = deg_to_rad( -7.5 )
		exp_bar.hide()
		_simplify()
	set_exp(data.level)

func set_health_node( node : Health ):
	health_node = node
	if not hp_style:
		hp_style = healthbar.get_theme_stylebox("fill")
	if not hp_bg:
		hp_bg = healthbar.get_theme_stylebox("background")

	healthbar.max_value = health_node.max_value
	healthbar.value = health_node.value
	_update_bar_color()
	health_display.text = HP_DISPLAY % [int(health_node.value), int(health_node.max_value)]
	
	if not health_node.health_changed.is_connected(_on_health_changed):
		health_node.health_changed.connect(_on_health_changed)

func set_exp( level ): 
	level_lbl.text = LVL_DISPLAY %  max(level, 1)
	exp_bar.max_value = data.experience_required
	exp_bar.value = data.experience
	
	if not data.gained_exp.is_connected(exp_bar._on_exp_gained):
		data.gained_exp.connect(exp_bar._on_exp_gained)

func update():
	set_health_node(health_node)
	#set_exp(data.level)
	_update_bar_color()
	#updated.emit(combatant)

func _simplify():
	$"%Health Display".hide()
	healthbar.custom_minimum_size = Vector2(128, 16)

func _get_hp_ratio():
	return healthbar.value / healthbar.max_value

func _update_bar_color():
	hp_style.bg_color = ( hp_gradient.sample( _get_hp_ratio() ) )
	healthbar.add_theme_stylebox_override( "fill", hp_style )
	hp_bg.bg_color = ( hp_bg_gradient.sample( _get_hp_ratio() ) )
	healthbar.add_theme_stylebox_override( "background", hp_bg )

#region SIGNAL FUNCTIONS
func _on_health_changed( _health, discrete := true ):
	healthbar.value = _health
	_update_bar_color()
	update()

func _on_dead( combatant : Combatant ): pass
#endregion

# EOF #
