extends Resource
class_name SavedTerrain

@export var layers: Array[PackedInt32Array]

# track this to make the save file easier to read
@export var _class_name: String

func save(terrain:Terrain):
    self._class_name = 'SavedTerrain'

    layers = []
    for layer_number in terrain.get_layers_count():
        layers.append(terrain.get("layer_"+str(layer_number)+"/tile_data"))
