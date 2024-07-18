extends 'common_action_leaf.gd'

@onready var exploration_paths:Array = []
@onready var path_picker = 0


func tick(actor, blackboard):
    exploration_paths = []
    var region_from_unit:Region = blackboard.get_value("region_from_unit")
    #print("set move to unexplored; region ",region_from_unit,"; unit ",actor,"; position ",actor.position,"/",Global.as_grid(actor.position))
    if region_from_unit == null: return FAILURE
    #print("set move to unexplored 2")

    var max_search_radius = region_from_unit.get_max_distance()

    for search_radius in range(actor.vision.distance + 1, max_search_radius + 1):
        set_exploration_paths(actor, search_radius, blackboard, region_from_unit)
        #print("set move to unexplored path: ",exploration_path)
        #print(Global.array_as_grid(exploration_path))
        if exploration_paths.is_empty(): continue
        path_picker = path_picker % exploration_paths.size()
        #print("unit ",actor," at ",actor.position,"/",Global.as_grid(actor.position)," radius ",search_radius,", path count ",exploration_paths.size()," picking element ",path_picker)
        #for path in exploration_paths:
            #print("path ",path)
            #print("grid path ",Global.array_as_grid(path))
        var exploration_path = exploration_paths[path_picker]
        if exploration_path.size() > 1:
            path_picker += 1
            blackboard.set_value("move_position", exploration_path[1])
            return SUCCESS
    #print("set move to unexplored 3")

    return FAILURE


func is_diagonal(path:PackedVector2Array) -> bool:
    if path.size() != 2: return false
    #print("checking path ",Global.array_as_grid(path)," diagonality")
    if path[0].x == path[1].x: return false
    if path[0].y == path[1].y: return false
    #print("path is diagonal")
    return true


func set_exploration_paths(actor:Unit, search_radius:int, blackboard:Blackboard, region:Region):
    var center = actor.get_world_position()
    var terrain = blackboard.get_value("terrain")

    var perimeter:Array[Vector2] = get_unexplored_perimeter(actor, search_radius, blackboard.get_value("explored"), region)
    #debug_perimeter(actor, blackboard, perimeter)
    var paths = []
    #var optimal_path = null
    for coordinate in perimeter:
        var path = terrain.find_coordinate_path(center, coordinate, actor.navigation)
        #print("checking exploration path 1: ",path)
        if path.is_empty(): continue
        # remove last element of path, since this falls within unexplored space
        #path = path.slice(0, -1)
        #print("checking exploration path 2: ",path)
        #if not terrain.is_point_walkable(path[-1], actor.navigation): continue
        #print("checking exploration path 3: ",path)
        #print("unit ",actor," path to ",coordinate,": ",path)
        if paths.is_empty():
            paths.append(path)
            continue

        var previous_path = paths[-1]
        if path.size() < previous_path.size():
            paths = [path]
            continue

        if path.size() > previous_path.size():
            continue

        # same last element, ignore it
        if previous_path[-1] == path[-1]:
            continue

        paths.append(path)

    var straight_paths = []
    var diagonal_paths = []
    for path in paths:
        if is_diagonal(path):
            diagonal_paths.append(path)
            continue
        straight_paths.append(path)

    if straight_paths.size() == 0:
        exploration_paths = paths
        return

        #var optimal_neighbors = terrain.get_in_bounds_neighbors(Global.as_grid(optimal_last))
        #var last_neighbors = terrain.get_in_bounds_neighbors(Global.as_grid(path_last))
        #print("comparing neighbors of path end points: ",optimal_neighbors," and ",last_neighbors)
    #if paths.is_empty():
    #    return
    #print("unit ",actor," radius ",search_radius," setting to first of paths: ", paths)
    exploration_paths = straight_paths


