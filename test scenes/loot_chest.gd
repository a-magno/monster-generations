extends Area2D
class_name InteractionArea

@export var oneshot_open := false
enum {
	CLOSED,
	LOOTED
}
var state = CLOSED
var loot : Array = ["potion", "potion"]

func interact( actor ):
	if state == CLOSED:
		$AnimatedSprite2D.play("open")
		state = LOOTED
		var item = ItemManager.get_random_item()
		PlayerData.add_item( item )
		loot.clear()
		return "Added item %s" % item.name
	return str(loot) if not loot.is_empty() else "No loot here..."
	#FloatingText.show_text("No loot here...", 2.0, global_position)
