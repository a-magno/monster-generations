extends RefCounted
class_name Stat

signal value_changed(new_value: float)
signal max_value_changed(new_max_value: float)

var id: StringName
var owner: Resource
var formula_override = null
var base: float = 0.0
var EV: float = 0.0
var IV: float = 0.0
var add: float = 0.0
var mult: float = 0.0

# Private variables to store the actual values
var _max_value: int = 0
var _value: int = 0

# Getter and Setter for max_value
func set_max_value(v: int) -> void:
	var old_max = _max_value
	var ratio: float = 1.0
	if old_max > 0:
		ratio = roundf(float(_value) / float(old_max))
	_max_value = v
	max_value_changed.emit(_max_value)
	# Adjust _value based on the new max_value and previous ratio
	_value = int(round(float(_max_value) * ratio))
	if _value < 1:  # Ensure _value is at least 1
		_value = 1
	if _value > _max_value:  # Ensure _value does not exceed max_value
		_value = _max_value
	value_changed.emit(_value)

func get_max_value() -> int:
	return _max_value

# Getter and Setter for value
func set_value(v: int) -> void:
	if v != _value:
		_value = clamp(v, 1, _max_value)
		value_changed.emit(_value)

func get_value() -> int:
	return _value

# Define the properties with setget
var max_value: int : set = set_max_value, get = get_max_value
var value: int : set = set_value, get = get_value

func _init(_id: StringName, _base: float, _o: Resource, _formula = null):
	randomize()
	id = _id
	owner = _o
	base = _base
	formula_override = _formula
	IV = float(randi_range(1, 15))
	_max_value = calculate()
	# Initialize _value to _max_value
	_value = int(_max_value)
	#print_debug(_value, "/", _max_value)
	# Emit initial signals
	max_value_changed.emit(_max_value)
	value_changed.emit(_value)
	# Uncomment for debugging
	# print("%s : %d" % [id, _value])

func calculate(formula_override_input = formula_override) -> float:
	var _value = base
	var expr = Expression.new()
	var inputs = {
		"IV": int(IV),
		"EV": int(EV),
		"base": int(base),
		"level": max(owner.level, 1),
		# "nature": owner.nature.get_mod(id)
	}
	# Default formula
	var formula = "(((IV + 2 * base + (EV / 4)) * level / 100) + 5)"  # * nature
	if formula_override_input:
		formula = formula_override_input

	var parse_res = expr.parse(formula, inputs.keys())
	if parse_res != OK:
		print(expr.get_error_text())
		return 0.0
	var res = expr.execute(inputs.values())
	if expr.has_execute_failed():
		return 0.0
	_value = res
	#_value = (_value + add) * (1.0 + mult)
	return _value

func increase(amount: int) -> void:
	value = _value + amount

func decrease(amount: int) -> void:
	value = _value - amount

func connect_to_signal( callable : Callable, signal_name : StringName):
	if not is_connected(signal_name, callable):
		connect(signal_name, callable)
	
func serialize():
	return {
		"value": value,
		"EV": EV,
		"IV": IV,
		"object": self
	}
