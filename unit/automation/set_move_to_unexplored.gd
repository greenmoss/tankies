extends 'common_action_leaf.gd'

@onready var exploration_path:PackedVector2Array = []


func tick(actor, blackboard):
    var region_from_unit:Region = blackboard.get_value("region_from_unit")
    if region_from_unit == null: return FAILURE

    var max_search_radius = region_from_unit.get_max_distance()

    for search_radius in range(actor.vision.distance + 1, max_search_radius + 1):
        set_exploration_path(actor, search_radius, blackboard, region_from_unit)
        if exploration_path.size() > 1:
            blackboard.set_value("move_position", exploration_path[1])
            return SUCCESS

    return FAILURE


func set_exploration_path(actor:Unit, search_radius:int, blackboard:Blackboard, region:Region):
    var center = actor.get_world_position()
    var terrain = blackboard.get_value("terrain")

    var perimeter:Array[Vector2] = get_unexplored_perimeter(actor, search_radius, blackboard.get_value("explored"), region)
    for coordinate in perimeter:
        var path = terrain.find_coordinate_path(center, coordinate, actor.navigation)
        if path.is_empty(): continue
        path.remove_at(path.size() - 1)
        if not terrain.is_point_walkable(path[-1], actor.navigation): continue
        exploration_path = path
        return


