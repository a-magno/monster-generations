extends Resource
class_name Tamer

@export var id : StringName
@export var name : String :
	get():
		if name.is_empty():
			return id
		return name

@export var party : Array[Monster]
