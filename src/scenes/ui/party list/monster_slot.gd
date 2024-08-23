extends PanelContainer

@onready var icon = %Icon
@onready var info = %Info
@onready var identity = %Identity
@onready var stats = %Stats
var data : Monster
const IDENTITY_FORMAT = "{name} ({gender}) - Lv.{level}\n[{types}]"
const STAT_FORMAT = "[{id}: {value}]"
const HP_FORMAT = "[{id}: {value}/{max}]"

func set_data( d : Monster):
	if not data:
		data = d
	icon.texture = data.icon
	identity.text = IDENTITY_FORMAT.format({
		"name" : data.nickname,
		"gender": ["-", "M", "F"][data.gender],
		"level": data.get_level(),
		"types" : "%s / %s" % [Typing.as_string(data.type1), Typing.as_string(data.type2)] if data.type2 else Typing.as_string(data.type1)
	})
	set_stats()
	open()

func open():
	info.show()

func close():
	info.hide()

func set_stats():
	for c in stats.get_children():
		c.queue_free()
	for key in data.stats.keys():
		var lbl = Label.new()
		var stat =  data.get_stat(key)
		var txt = HP_FORMAT if key == &"hp" else STAT_FORMAT
		lbl.text = txt.format({
			"id":key.to_upper(),
			"value": stat.value,
			"max": stat.max
		})
		if not stat.self.value_changed.is_connected(_on_stat_changed):
			stat.self.value_changed.connect(_on_stat_changed)
		if not stat.self.max_value_changed.is_connected(_on_stat_changed):
			stat.self.max_value_changed.connect(_on_stat_changed)
		stats.add_child(lbl)

func _on_stat_changed( stat ):
	set_stats()
