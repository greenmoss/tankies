extends 'common_action_leaf.gd'


func tick(actor, blackboard):
    var regions = blackboard.get_value("regions")
    var unexplored_region:Region = regions.get_from_unit(actor)
    if unexplored_region == null: return FAILURE

    var max_search_radius = unexplored_region.get_max_distance()
    blackboard.set_value("exploration_path", null)

    for search_radius in range(actor.vision.distance + 1, max_search_radius + 1):
        set_exploration_path(actor, search_radius, blackboard, unexplored_region)
        if blackboard.get_value("exploration_path") != null:
            blackboard.set_value("move_position", blackboard.get_value("exploration_path")[1])
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
        blackboard.set_value("exploration_path", path)
        return


