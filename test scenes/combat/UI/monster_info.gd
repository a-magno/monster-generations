extends PanelContainer

signal updated

@export var hp_gradient : Gradient

@onready var monster_name: Label = %Name
@onready var level_lbl: Label = %Level
@onready var healthbar: ProgressBar = %Healthbar
@onready var health_display: Label = %"Health Display"

@onready var exp_bar: ProgressBar = %ExpBar
@onready var gender_lbl: Label = %Gender

var combatant : Combatant
var health_node : Health :
	set(h):
		health_node = h
var data : Monster : 
	set(d):
		data = d

var hp_style : StyleBoxFlat
var tween

const HP_DISPLAY = "%d / %d"

func _ready():
	combatant.turn_done.connect(
		func():
			updated.emit(combatant)
	)

func _process(delta):
	if not tween:
		return
	health_display.text = HP_DISPLAY % [int(health_node.value), int(health_node.max_value)]

func set_data(_data : Monster):
	data = _data
	monster_name.text = data.get_nickname()
	#print_debug("monster level %d" % data.level)
	if data.captured_status == Monster.TAMED:
		exp_bar.show()
		set_exp_bar(data.level)
		data.leveled_up.connect(update)
	else:
		exp_bar.hide()
		set_exp_bar(data.level)

func set_healthbar(_health : Health):
	health_node = _health
	if not hp_style:
		hp_style = healthbar.get_theme_stylebox("fill")
	healthbar.max_value = health_node.max_value
	healthbar.value = health_node.value
	health_display.text = HP_DISPLAY % [int(health_node.value), int(health_node.max_value)]
	if not health_node.health_changed.is_connected(_on_health_changed):
		health_node.health_changed.connect(_on_health_changed)
	_update_bar_color()
	#updated.emit()

func set_exp_bar(level):
	level_lbl.text = "Lv. %d" %  max(data.level, 1)
	exp_bar.max_value = data._calculate_exp_to_next_level(level)
	exp_bar.value = data.total_exp
	if not data.gained_exp.is_connected(_on_exp_gained):
		data.gained_exp.connect(_on_exp_gained)
	#updated.emit()

func update():
	set_healthbar( health_node )
	set_exp_bar( data.level )
	updated.emit(combatant)

#region SIGNAL FUNCTIONS #

func _on_exp_gained(_exp, discrete := true):
	#exp_bar.value = exp
	if not discrete:
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(exp_bar, "value", _exp, 0.4).from_current()
		await tween.finished
	else:
		exp_bar.value = _exp
	update()

func _on_health_changed(new_value, discrete := false):
	#healthbar.value = new_value
	if not discrete:
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(healthbar, "value", new_value, 0.4).from_current().set_ease(Tween.EASE_IN_OUT)
		await tween.finished
	else:
		healthbar.value = new_value
	_update_bar_color()
	update()

func _get_hp_ratio():
	return healthbar.value / healthbar.max_value

func _update_bar_color():
	hp_style.bg_color = ( hp_gradient.sample( _get_hp_ratio() ) )
	healthbar.add_theme_stylebox_override( "fill", hp_style )
#endregion
# EOF #
