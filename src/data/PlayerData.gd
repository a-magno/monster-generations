extends DataCore
#class_name PlayerData

var name : StringName
var id : int
var _secret_id : int
var gender : int
var money : int

var party : Array[MonsterCore]

var inventory : Array

func initialize():
	id = randi()
	_secret_id = get_id(true)
	id = get_id()

func get_id( secret : bool = false) -> int:
	var str = str(id).pad_zeros(10)
	if secret: return str.left(4).pad_zeros(4).to_int()
	else: return str.right(6).pad_zeros(6).to_int()
