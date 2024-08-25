extends PanelContainer

@onready var icon = %Icon
@onready var info = %Info
@onready var identity = %Identity
@onready var stats = %Stats

@onready var healthbar = %Healthbar
@onready var health_display = %"Health Display"
@onready var exp_bar = %ExpBar

var t
var data : Monster
#const IDENTITY_FORMAT = "{name} ({gender}) - Lv.{level}\n[{types}]"
const IDENTITY_FORMAT = "{name} ({gender}) - Lv.{level}"
const STAT_FORMAT = "[{id}: {value}]"
const HP_FORMAT = "[{id}: {value}/{max}]"

func _process(delta):
	if t:
		health_display.text = "%3d/%3d" % [ healthbar.value, healthbar.max_value]

func set_data( d : Monster):
	if not data:
		data = d
	icon.texture = data.icon
	identity.text = IDENTITY_FORMAT.format({
		"name" : data.nickname,
		"gender": ["-", "M", "F"][data.gender],
		"level": "%3d" % data.get_level(),
		"types" : "%s / %s" % [Typing.as_string(data.type1), Typing.as_string(data.type2)] if data.type2 else Typing.as_string(data.type1)
	})
	
	data.get_stat(&"hp").self.connect_to_signal(_update_max_health, "max_value_changed")
	data.get_stat(&"hp").self.connect_to_signal(_update_health, "value_changed")
	healthbar.value = data.get_stat(&"hp").value
	healthbar.max_value = data.get_stat(&"hp").max
	health_display.text = "%3d/%3d" % [ healthbar.value, healthbar.max_value]
	#set_stats()
	open()

func _update_health(new_value):
	#healthbar.value = new_value
	t = create_tween()
	t.set_parallel(true)
	t.tween_property(healthbar, "value", new_value, 0.3).from_current().set_ease(Tween.EASE_IN)
	await t.finished

func _update_max_health(new_value):
	healthbar.max_value = new_value

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
