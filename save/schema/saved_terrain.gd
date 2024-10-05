extends Resource
class_name SavedTerrain

@export var layers: Array[PackedInt32Array]
@export var tile_map_data: PackedByteArray

# track this to make the save file easier to read
@export var _class_name: String

func save(terrain:Terrain):
    self._class_name = 'SavedTerrain'

    tile_map_data = terrain.get('tile_map_data')
    # REF
    #layers = []
    #for layer_number in terrain.get_layers_count():
    #    layers.append(terrain.get("layer_"+str(layer_number)+"/tile_data"))
