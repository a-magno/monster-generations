extends PanelContainer
class_name InventorySlot

@onready var texture_rect: TextureRect = $TextureRect
@export var item : Item = null :
	set(v):
		item = v
		if v != null:
			$TextureRect.texture = v.icon
			$Label.text = "x%d" % v.stack
		else:
			$TextureRect.texture = null
			$Label.text = ""

func get_preview():
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture_rect.texture
 
	var preview = Control.new()
	preview.add_child(preview_texture)
 
	return preview
 
func _get_drag_data(_at_position):
	set_drag_preview(get_preview())
	return self
 
func _can_drop_data(_pos, data):
	return data is InventorySlot
 
func _drop_data(_at_position, data):
	var temp = item
	item = data.item
	data.item = temp
