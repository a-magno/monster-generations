extends Resource
class_name BaseMove

enum DmgType {
	PHYSICAL,
	SPECIAL,
	STATUS_EFFECT
}

@export var id : StringName
@export var name : String
@export var max_uses : float = 0.0 :
	set(v):
		max_uses = v
		uses_left = max_uses
var uses_left
@export var dmg_type : DmgType :
	set(t):
		dmg_type = t
		match(dmg_type):
			DmgType.PHYSICAL:
				dmg_key = &"atk"
				def_key = &"def"
			DmgType.SPECIAL:
				dmg_key = &"spAtk"
				def_key = &"spDef"
			DmgType.STATUS_EFFECT:
				dmg_key = &""
@export var power : float = 10.0
@export var accuracy : float = 100.0
var dmg_key : StringName
var def_key : String
@export var type : Typing.Types
@export_multiline var description : String
