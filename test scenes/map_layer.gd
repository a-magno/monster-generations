extends TileMapLayer

@onready var ground = $Ground
@onready var paths = $Paths
@onready var elevations = $Elevations

func check_walkable( pos : Vector2i )->bool:
	var data = {
		"ground" : ground.get_cell_tile_data( pos ),
		"paths" : paths.get_cell_tile_data( pos ),
		"elevation" : elevations.get_cell_tile_data( pos )
	}
	
	for d : TileData in data.values():
		if d:
			return d.get_custom_data("walkable")
	return false

func get_floor_type( at : Vector2 ):
	var cell = local_to_map( at )
	var data = {
		"ground" : ground.get_cell_tile_data( cell ),
		"paths" : paths.get_cell_tile_data( cell ),
		"elevation" : elevations.get_cell_tile_data( cell )
	}
	for d : TileData in data.values():
		if d:
			return d.get_custom_data("floor_type") if d.get_custom_data("floor_type") else "void"
