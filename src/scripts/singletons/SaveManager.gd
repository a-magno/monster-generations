extends Node

const ENCRYPT_PASS_TEST = "zkdnasjkdn"
const SAVE_DIR = "user://"
const FILE_FORMAT = "{id}.sav"

var SAVE_PATH = SAVE_DIR + FILE_FORMAT
#
func _ready():
	get_save_files()
	#if not DirAccess.dir_exists_absolute(SAVE_DIR):
		#DirAccess.open(SAVE_DIR)

func save_game(save_id = PlayerHandler.get_id()):
	SAVE_PATH = SAVE_PATH.format({ "id": save_id })
	var save_file = get_save_file( save_id )	
	var json_string = JSON.stringify( PlayerHandler.serialize() )
	save_file.store_line(json_string)
	Event.file_save_sucessful.emit()

func load_game(save_id):
	print("Loading game...")
	var save_file = get_save_file(save_id)
	#while save_file.get_position() < save_file.get_length():
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_res = json.parse(json_string)
	var data = json.get_data()
	PlayerHandler.deserialize( data )

func get_save_file(save_id):
	SAVE_PATH = SAVE_PATH.format({ "id": save_id })
	if not FileAccess.file_exists(SAVE_PATH):
		push_warning("Save file not found...")
		return
	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ_WRITE)
	if not save_file:
		Event.file_load_error.emit("ERROR %s" % str( FileAccess.get_open_error() ))
		return
	return save_file

func get_save_files():
	var dir = DirAccess.open(SAVE_DIR)
	print( dir.get_files() )
	
# EOF #
