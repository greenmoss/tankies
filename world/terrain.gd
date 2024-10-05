extends TileMapLayer
class_name Terrain

const CELL_SIZE = Vector2i(Global.tile_size, Global.tile_size)

var x_max:int
var x_min:int
var y_max:int
var y_min:int
var source_tile_counts:Dictionary

# for every physics layer in the terrain tileset
# PLUS the "-1" group, which is "no assigned physics layer"
# find all tile types associated with that physics layer
# note these values correspond with "group_names"
# for example
# { -1: [<TileData#0001>],
#    0: [],
#    1: [<TileData#0002>, <TileData#0003>],
#    2: [<TileData#0004>] }
var physics_layers_tiles:Dictionary

# for every tile type in the terrain tileset
# find the tile group associated with that tile
# note these values correspond with "group_names"
# for example
# { <TileData#0001>: -1,
#   <TileData#0002>: 1,
#   <TileData#0003>: 1,
#   <TileData#0004>: 2 }
var tile_groups:Dictionary

# TODO: derive these from project settings where possible
# use the collision layer?
# example: tile_set.get_physics_layer_collision_layer(layer_id)
# returns 1, 2, 4, etc, so use bit-wise math?
# project settings assign via the bit-wise number, NOT the physics layer!
var group_names = {
    -1: 'port',
    0: 'barrier',
    1: 'land',
    2: 'ocean',
}

# navigation maps: land, ocean, air
# initialized within set_navigation()
var navigation:Dictionary

# if we have blocker tiles surrounding the tilemap layer, how wide are they
@export var blocker_margin:int


func _ready():
    set_limits()
    set_source_tile_counts()
    set_physics_layers_tiles()
    set_tile_groups()
    set_navigation()


func block_navigation_point(layer_name:String, point:Vector2i):
    navigation[layer_name].set_point_solid(point)


func find_coordinate_path(map_start_coordinate:Vector2, map_end_coordinate:Vector2, group_name:String):
    return navigation[group_name].get_point_path(map_start_coordinate, map_end_coordinate)


func find_path(local_start_point:Vector2i, local_end_point:Vector2i, group_name:String):
    var start_point = local_to_map(local_start_point)
    var end_point = local_to_map(local_end_point)
    return navigation[group_name].get_point_path(start_point, end_point)


func get_group_name(group_id:int) -> String:
    return group_names[group_id]


func get_physics_colliders(layer_id:int) -> int:
    # handle "-1" layer id
    if (layer_id < 0) or (layer_id >= tile_set.get_physics_layers_count()):
        return 0
    return tile_set.get_physics_layer_collision_layer(layer_id)


func get_position_group(map_position:Vector2i) -> int:
    return tile_groups[get_surface_tile(map_position)]


func get_surface_tile(map_position:Vector2i):
    return get_cell_tile_data(map_position)


func init_navigation(layer_name:String):
    var navigation_layer = AStarGrid2D.new()
    navigation_layer.region = Rect2i(x_min, y_min, x_max + 1, y_max + 1)
    navigation_layer.cell_size = CELL_SIZE
    navigation_layer.offset = CELL_SIZE * 0.5
    navigation_layer.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    navigation_layer.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    navigation_layer.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
    navigation_layer.update()
    navigation[layer_name] = navigation_layer


func is_point_walkable(local_position, group_name:String):
    var map_position = local_to_map(local_position)
    if navigation[group_name].is_in_boundsv(map_position):
        return not navigation[group_name].is_point_solid(map_position)
    return false


func restore(saved_terrain: SavedTerrain):
    clear()
    set("tile_map_data", saved_terrain.tile_map_data)
    #print(tile_groups)
    #if saved_terrain.tile_map_data.is_empty():
    #    print("missing tile_map_data, trying to convert ")
    #    set("tile_map_data", saved_terrain.layers[0].to_byte_array())
    #else:
    #    set("tile_map_data", saved_terrain.tile_map_data)
    #print(tile_map_data)
    #REF
    #print("old layers ", saved_terrain.layers[0])
    #print("old layers as PackedByteArray ", saved_terrain.layers[0].to_byte_array())
    #print("new tile_map_data ", saved_terrain.tile_map_data)
    #var layer_number = 0
    #for saved_layer in saved_terrain.layers:
    #    set("layer_"+str(layer_number)+"/tile_data", saved_layer)
    #    layer_number += 1
    set_navigation()


func round_local_position(local_position):
    return map_to_local(local_to_map(local_position))


func save(saved: SavedWorld):
    saved.save_terrain(self)


func set_navigation():
    init_navigation('air')
    init_navigation('land')
    init_navigation('ocean')

    for x in range(x_min, x_max + 1):
        for y in range(y_min, y_max + 1):
            var point = Vector2i(x, y)
            var group_name = get_group_name(get_position_group(point))
            if group_name == 'land':
                block_navigation_point('ocean', point)
            if group_name == 'ocean':
                block_navigation_point('land', point)


func set_limits():
    # TODO: derive these from tile map
    x_max = 23
    x_min = 0
    y_max = 13
    y_min = 0


func set_physics_layers_tiles():
    var physics_layers_count = tile_set.get_physics_layers_count()
    physics_layers_tiles = {}
    if source_tile_counts == null:
        set_source_tile_counts()
    physics_layers_tiles[-1] = []
    for layer_id in physics_layers_count:
        physics_layers_tiles[layer_id] = []
    for tile in source_tile_counts.keys():
        var assigned_tile = false
        for layer_id in physics_layers_count:
            if tile.get_collision_polygons_count(layer_id) == 0: continue
            physics_layers_tiles[layer_id].append(tile)
            assigned_tile = true
        if not assigned_tile:
            physics_layers_tiles[-1].append(tile)
    return physics_layers_tiles


func set_tile_groups():
    tile_groups = {}
    if physics_layers_tiles == null:
        set_physics_layers_tiles()
    for layer in physics_layers_tiles.keys():
        for tile in physics_layers_tiles[layer]:
            tile_groups[tile] = layer


func set_source_tile_counts():
    source_tile_counts = {}
    for x in range(x_min, x_max):
        for y in range(y_min, y_max):
            var pos = Vector2i(x, y)
            var source_tile = get_surface_tile(pos)
            if not source_tile in source_tile_counts:
                source_tile_counts[source_tile] = 0
            source_tile_counts[source_tile] += 1
