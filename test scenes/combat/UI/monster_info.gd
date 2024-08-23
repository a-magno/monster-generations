extends PanelContainer

signal updated

@export var hp_gradient : Gradient

@onready var monster_name: Label = %Name
@onready var level_lbl: Label = %Level
@onready var healthbar: ProgressBar = %Healthbar
@onready var health_display: Label = %"Health Display"
var hp_style : StyleBoxFlat
var tween
@onready var exp_bar: ProgressBar = %ExpBar
@onready var gender_lbl: Label = %Gender

@onready var health_node : Health :
	set(h):
		health_node = h
@onready var data : Monster : 
	set(d):
		data = d
var combatant
const display_format = "%d / %d"

func _ready() -> void:
	monster_name.text = data.get_nickname()
	#print_debug("monster level %d" % data.level)
	if data.captured_status == Monster.TAMED:
		exp_bar.show()
		data.leveled_up.connect(_set_exp_bar)
		_set_exp_bar(data.level)
	_set_healthbar()
	health_display.text = "%d / %d" % [healthbar.value, health_node.max_value]

func _process(delta):
	if not tween:
		return
	health_display.text = "%d / %d" % [healthbar.value, health_node.max_value]
	
func _set_healthbar():
	if not hp_style:
		hp_style = healthbar.get_theme_stylebox("fill")
	healthbar.max_value = health_node.max_value
	health_display.text = display_format.format([int(health_node.value), int(health_node.max_value)])
	health_node.health_changed.connect(_on_health_changed)
	_update_bar_color()
	#updated.emit()

func _set_exp_bar(level):
	level_lbl.text = "Lv. %d" %  max(data.level, 1)
	exp_bar.max_value = data._calculate_exp_to_next_level(level)
	exp_bar.value = data.total_exp
	data.gained_exp.connect(_on_exp_gained)
	#updated.emit()

func _on_exp_gained(_exp):
	#exp_bar.value = exp
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(exp_bar, "value", _exp, 0.4).from_current()
	await tween.finished
	updated.emit(combatant)

func _on_health_changed(new_value):
	#healthbar.value = new_value
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(healthbar, "value", new_value, 0.4).from_current().set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	_update_bar_color()
	updated.emit(combatant)

func _get_hp_ratio():
	return healthbar.value / healthbar.max_value

func _update_bar_color():
	hp_style.bg_color = ( hp_gradient.sample( _get_hp_ratio() ) )
	healthbar.add_theme_stylebox_override( "fill", hp_style )
