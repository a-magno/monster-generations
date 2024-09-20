@tool
extends ProgressBar

@export var gradient : Gradient
@export var display_number : bool = true :
	set(b):
		display_number = b
		if display_number:
			$Label.show()
		else:
			$Label.hide()

var health_node : Health
var hp_style : StyleBox

func _ready():
	hp_style = get_theme_stylebox("fill")
	
func initialize( health : Health ):
	health_node = health
	max_value = health_node.max_value
	value = health_node.value
	
	health_node.health_changed.connect(_on_value_changed)

func _on_value_changed(_v):
	value = _v
	$Label.text = "%3d/%3d" % [value, max_value]
	_update_bar_color()

func _update_bar_color():
	hp_style.bg_color = ( gradient.sample( value / max_value ) )
	add_theme_stylebox_override( "fill", hp_style )
