extends Control

@onready var item_list: ItemList = %ItemList
var is_open := false

func open():
	init()
	show()

func close():
	set_process(false)
	set_physics_process(false)
	hide()

func init():
	item_list.clear()
	for item : Item in PlayerData.inventory:
		print(item.id)
		var idx = item_list.item_count
		item_list.add_item("%s" % item.name, item.icon, false)
		var tooltip = "x%d \n%s" % [ item.stack, item.description ]
		item_list.set_item_tooltip( idx, tooltip )
		#item_list.add_item("x%d" % item.stack, null, false)
		item_list.set_item_metadata(idx, item)
