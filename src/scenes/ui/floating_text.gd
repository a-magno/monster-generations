extends RichTextLabel

signal display_done

var init_pos : Vector2
		
func _ready() -> void:
	hide()

func display_text(_text, _lifetime := 1.0):
	_reset()
	text = "[center]%s" % _text
	_offset(text)
	pivot_offset = size/2
	position -= pivot_offset/2
	show()
	await get_tree().create_timer(_lifetime).timeout
	
	var tween = create_tween()
	tween.set_parallel(true)
	var target_y = position.y - 32
	tween.tween_property(self, "position:y", target_y, _lifetime).set_ease(Tween.EASE_OUT).from_current()
	tween.tween_property(self, "modulate", Color(1,1,1, 0), _lifetime).set_ease(Tween.EASE_OUT)
	await tween.finished
	tween.kill()
	hide()
	
	return

func _reset():
	modulate = Color.WHITE
	position = init_pos
	text = ""

func _offset(_text):
	var font := get_theme_default_font()
	var font_size := get_theme_default_font_size()
	var glyph_index = font.get_glyph_index(font_size, _text.to_ascii_buffer()[0], 0)
	
	var primary_text_server := TextServerManager.get_primary_interface()
	for rid: RID in font.get_rids():
		var glyph_size := primary_text_server.font_get_glyph_size(rid, Vector2i(font_size, font_size), glyph_index)
		#print(glyph_size)
		position -= glyph_size / 2
