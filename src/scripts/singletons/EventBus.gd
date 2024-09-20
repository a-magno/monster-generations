extends Node

# For general menus such as pause, inventory, party, and crafting
signal menu_opened()
signal menu_closed()

# For things that prompt the player to stop for text
#signal player_begin_interaction()
#signal player_end_interaction()

# Signals for successful saving and loading
signal file_save_sucessful()
signal file_save_error( err )
signal file_load_sucessful()
signal file_load_error( err )

signal item_acquired( item : Item )
signal item_dropped( item : Item, world_pos : Vector2 )

signal monster_caught( monster : Monster )
