extends ProgressBar

@export var color_gradient : Gradient
@export var bg_gradient : Gradient
var hp_style : StyleBox
var bg_style : StyleBox

func _ready():
	if not hp_style:
		hp_style = get_theme_stylebox("fill")
	if not bg_style:
		bg_style = get_theme_stylebox("background")
	_update_color()
	value_changed.connect(
		func(v):
			_update_color()
	)
	

func _update_color():
	hp_style.bg_color = ( color_gradient.sample( _get_hp_ratio() ) )
	add_theme_stylebox_override( "fill", hp_style )
	bg_style.bg_color = ( bg_gradient.sample( _get_hp_ratio() ) )
	add_theme_stylebox_override( "background", bg_style )

func _get_hp_ratio():
	return value / max_value
