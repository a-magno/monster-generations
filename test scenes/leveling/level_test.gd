extends Node

signal gained_exp( data )
signal leveled_up( new_level )

@export var level : int = 1
@export var growth : Level.GrowthTypes
var experience : int
var exp_total : int
var exp_req : int = get_required_exp(level+1)


#region testing
func _ready():
	$ProgressBar.initialize(experience, exp_req)

func _process(delta: float) -> void:
	$Label.text = "Lv. %3d\nExp:%d\nNext Lv:%d" % [level, experience, exp_req]

#endregion

func get_required_exp( level ):
	match( growth ):
		Level.GrowthTypes.FAST:
			return Level.fast( level )
		Level.GrowthTypes.MEDIUM_FAST:
			return Level.medium_fast( level )
		Level.GrowthTypes.MEDIUM_SLOW:
			return Level.medium_slow( level )
		Level.GrowthTypes.SLOW:
			return Level.slow( level )
		_:
			return Level.slow(level)

func gain_experience( amount ):
	exp_total += amount
	experience += amount
	var growth_data = []
	while experience >= exp_req:
		experience -= exp_req
		growth_data.append([exp_req, exp_req])
		level_up()
		leveled_up.emit(level)
	growth_data.append([experience, exp_req])
	gained_exp.emit( growth_data )

func level_up():
	level += 1
	exp_req = get_required_exp(level+1)
	#handle learning new move

func _fast( n ):
	return 0.8 * pow(n, 3)

func _medium_fast( n ):
	return pow(n, 3)

func _medium_slow( n ):
	return 1.2*pow(n, 3) - (15 * pow(n, 2)) + 100*n - 140

func _slow( n ):
	return 1.25 * pow(n, 3)

func _on_button_pressed() -> void:
	gain_experience(randi_range(500, 5000))
