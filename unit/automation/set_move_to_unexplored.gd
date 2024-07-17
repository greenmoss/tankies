extends 'common_action_leaf.gd'

@onready var exploration_path:PackedVector2Array = []


func tick(actor, blackboard):
    exploration_path = []
    var region_from_unit:Region = blackboard.get_value("region_from_unit")
    #print("set move to unexplored; region ",region_from_unit,"; unit ",actor,"; position ",actor.position,"/",Global.as_grid(actor.position))
    if region_from_unit == null: return FAILURE
    #print("set move to unexplored 2")

    var max_search_radius = region_from_unit.get_max_distance()

    for search_radius in range(actor.vision.distance + 1, max_search_radius + 1):
        set_exploration_path(actor, search_radius, blackboard, region_from_unit)
        #print("set move to unexplored path: ",exploration_path)
        #print(Global.array_as_grid(exploration_path))
        if exploration_path.size() > 1:
            blackboard.set_value("move_position", exploration_path[1])
            return SUCCESS
    #print("set move to unexplored 3")

    return FAILURE


func set_exploration_path(actor:Unit, search_radius:int, blackboard:Blackboard, region:Region):
    var center = actor.get_world_position()
    var terrain = blackboard.get_value("terrain")

    var perimeter:Array[Vector2] = get_unexplored_perimeter(actor, search_radius, blackboard.get_value("explored"), region)
    #debug_perimeter(actor, blackboard, perimeter)
    for coordinate in perimeter:
        var path = terrain.find_coordinate_path(center, coordinate, actor.navigation)
        #print("checking exploration path 1: ",path)
        if path.is_empty(): continue
        path.remove_at(path.size() - 1)
        #print("checking exploration path 2: ",path)
        if not terrain.is_point_walkable(path[-1], actor.navigation): continue
        #print("checking exploration path 3: ",path)
        exploration_path = path
        return


