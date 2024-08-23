extends GridContainer
 
signal item_changed
 
#region Testing
#@export var ITEM : Item
#@export var ITEM2 : Item
#func _ready():
	#await get_tree().create_timer(0.2).timeout
	#add_item(ITEM)
	#await get_tree().create_timer(0.2).timeout
	#add_item(ITEM2)
#endregion
 
func open():
	for i in PlayerData.inventory:
		add_item(i)
	show()

func close():
	for i in PlayerData.inventory:
		remove_item(i)
	hide()

func add_item(item):
	for i in get_children():
		if i.item == null:
			i.item = item
			item_changed.emit()
			return
 
func remove_item(item):
	for i in get_children():
		if i.item == item:
			i.item = null
			item_changed.emit()
			return
 
func is_available(item):
	for i in get_children():
		if i.item == item:
			return true
	return false
 
# EOF #
