extends TileMap
class_name Terrain

# heavily inspired by
# https://github.com/godotengine/godot-demo-projects/tree/master/2d/navigation_astar
enum Tile { OBSTACLE, START_POINT, END_POINT }

const CELL_SIZE = Vector2i(80, 80)

# The object for pathfinding on 2D grids.
var _astar = AStarGrid2D.new()
var _start_point = Vector2i()
var _end_point = Vector2i()
var _path = PackedVector2Array()

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

# if we have blocker tiles surrounding the tilemap, how wide are they
@export var blocker_margin:int


func _ready():
    set_limits()
    set_source_tile_counts()
    set_physics_layers_tiles()
    set_tile_groups()
    set_astar()


func find_coordinate_path(map_start_coordinate, map_end_coordinate):
    _start_point = map_start_coordinate
    _end_point = map_end_coordinate
    _path = _astar.get_point_path(_start_point, _end_point)
    return _path.duplicate()


func find_path(local_start_point, local_end_point):
    _start_point = local_to_map(local_start_point)
    _end_point = local_to_map(local_end_point)
    _path = _astar.get_point_path(_start_point, _end_point)

    return _path.duplicate()


func get_physics_colliders(layer_id:int) -> int:
    # handle "-1" layer id
    if (layer_id < 0) or (layer_id >= tile_set.get_physics_layers_count()):
        return 0
    return tile_set.get_physics_layer_collision_layer(layer_id)


func get_position_group(map_position:Vector2i) -> int:
    return tile_groups[get_surface_tile(map_position)]


func get_surface_tile(map_position:Vector2i):
    # layer 0 is the surface
    # if we add more layers later, adjust layer names/numbers as required
    return get_cell_tile_data(0, map_position)


func is_point_walkable(local_position):
    var map_position = local_to_map(local_position)
    if _astar.is_in_boundsv(map_position):
        return not _astar.is_point_solid(map_position)
    return false


func restore(saved_terrain: SavedTerrain):
    clear()
    var layer_number = 0
    for saved_layer in saved_terrain.layers:
        set("layer_"+str(layer_number)+"/tile_data", saved_layer)
        layer_number += 1
    set_astar()


func round_local_position(local_position):
    return map_to_local(local_to_map(local_position))


func save(saved: SavedWorld):
    saved.save_terrain(self)


func set_astar():
    # Region should match the size of the playable area plus one (in tiles).
    _astar.region = Rect2i(x_min, y_min, x_max + 1, y_max + 1)
    _astar.cell_size = CELL_SIZE
    _astar.offset = CELL_SIZE * 0.5
    _astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    _astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    _astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
    _astar.update()

    for x in range(_astar.region.position.x, _astar.region.end.x):
        for y in range(_astar.region.position.y, _astar.region.end.y):
            var pos = Vector2i(x, y)
            if get_cell_source_id(0, pos) == Tile.OBSTACLE:
                _astar.set_point_solid(pos)


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
