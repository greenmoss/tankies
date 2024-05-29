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

# if we have blocker tiles surrounding the tilemap, how wide are they
@export var blocker_margin:int

func _ready():
    set_astar()

func set_astar():
    # Region should match the size of the playable area plus one (in tiles).
    # The playable area is 24x14 tiles
    _astar.region = Rect2i(0, 0, 25, 15)
    _astar.cell_size = CELL_SIZE
    _astar.offset = CELL_SIZE * 0.5
    _astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    _astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
    _astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
    _astar.update()

    for i in range(_astar.region.position.x, _astar.region.end.x):
        for j in range(_astar.region.position.y, _astar.region.end.y):
            var pos = Vector2i(i, j)
            if get_cell_source_id(0, pos) == Tile.OBSTACLE:
                _astar.set_point_solid(pos)


func round_local_position(local_position):
    return map_to_local(local_to_map(local_position))


func is_point_walkable(local_position):
    var map_position = local_to_map(local_position)
    if _astar.is_in_boundsv(map_position):
        return not _astar.is_point_solid(map_position)
    return false


func find_coordinate_path(map_start_coordinate, map_end_coordinate):
    # they are off by one, not sure why
    map_start_coordinate.x -= 1
    map_start_coordinate.y -= 1
    map_end_coordinate.x -= 1
    map_end_coordinate.y -= 1
    _start_point = map_start_coordinate
    _end_point = map_end_coordinate
    _path = _astar.get_point_path(_start_point, _end_point)

    return _path.duplicate()


func find_path(local_start_point, local_end_point):
    _start_point = local_to_map(local_start_point)
    _end_point = local_to_map(local_end_point)
    _path = _astar.get_point_path(_start_point, _end_point)

    return _path.duplicate()

func save(saved: SavedWorld):
    saved.save_terrain(self)

func restore(saved_terrain: SavedTerrain):
    clear()
    var layer_number = 0
    for saved_layer in saved_terrain.layers:
        set("layer_"+str(layer_number)+"/tile_data", saved_layer)
        layer_number += 1
    set_astar()
