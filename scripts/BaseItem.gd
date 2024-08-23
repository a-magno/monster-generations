extends Resource
class_name Item

const MAX_STACK := 99

enum ItemType{
	CONSUMABLE,
	KEY_ITEM,
	BATTLE_EQUIP,
	MATERIAL
}

@export var id : StringName
@export var name : String
@export var icon : Texture
@export var type : ItemType = 0
@export_multiline var description : String
@export var value : int = 100
@export var weight : float = 1.0
@export var can_stack := true
@export var max_stack := MAX_STACK
var stack : int = 1
@export var recipes : Array[ItemRecipe]

func can_use( target : Combatant ):
	return type == ItemType.CONSUMABLE
