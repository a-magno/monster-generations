extends Button

signal move_selected( data )

@export var data : BaseMove
@export var move_name : Label
@export var description_label : RichTextLabel
@export var panel : Panel

var done_ready := false
const DESC_FORMAT = "[center]{value}/{max_value}"

func _ready():
	set_data(data)
	pressed.connect(
		func():
			print("%s Used" % data.name)
			move_selected.emit(data)
	)

func set_data( _data : BaseMove ):
	data = _data
	if not _data: return
	move_name.text = data.name
	update()
	if not data.move_used.is_connected(update):
		data.move_used.connect(update)

func update():
	description_label.text = DESC_FORMAT.format({
		"value": "%d" % data.uses_left,
		"max_value": "%d" % data.max_uses
	})
	#var stylebox = panel.get_theme_stylebox("panel")
	#stylebox.bg_color = Typing.colours[data.type]
	#panel.add_theme_stylebox_override("panel", stylebox)
