@tool
extends 'common_action_leaf.gd'


func tick(actor, blackboard):
    var path_to_unhaul:PackedVector2Array = []
    blackboard.set_value('unhaul_to_unexplored_path', path_to_unhaul)
    blackboard.set_value('unhaul_to_unexplored_region', null)

    if not actor.is_hauling(): return FAILURE

    var unit = get_idle_hauled(actor)
    if unit == null: return FAILURE

    var regions = blackboard.get_value("regions")
    var unexplored_region:Region = regions.get_from_unit(actor)
    if unexplored_region == null: return FAILURE

    var max_search_radius = unexplored_region.get_max_distance()

    for search_radius in range(actor.vision.distance + 1, max_search_radius + 1):
        set_unhaul_exploration_path(actor, unit, search_radius, blackboard, unexplored_region)
        if not blackboard.get_value("unhaul_to_unexplored_path").is_empty():
            return SUCCESS

    return FAILURE


func set_unhaul_exploration_path(actor:Unit, unit:Unit, search_radius:int, blackboard:Blackboard, region:Region):
    var center = actor.get_world_position()
    var obstacles = blackboard.get_value("obstacles")
    var terrain = blackboard.get_value("terrain")

    var path_to_unhaul:PackedVector2Array = blackboard.get_value('unhaul_to_unexplored_path')

    var perimeter:Array[Vector2] = get_unexplored_perimeter(actor, search_radius, blackboard.get_value("explored"), region)
    for coordinate in perimeter:
        var path = terrain.find_coordinate_path(center, coordinate, 'air')
        if path.is_empty(): continue
        if not terrain.is_point_walkable(path[-1], unit.navigation): continue

        var regions = blackboard.get_value("regions")
        var target_regions = regions.get_from_position(path[-1])
        var target_region:Region = null
        for check_region in target_regions:
            if (unit.get_colliders() & check_region.colliders) != 0: continue
            target_region = check_region
        if target_region == null: continue

        var approach_position = target_region.get_approach_position(path)
        if approach_position == Vector2.LEFT:
            push_warning("could not find air path from hauler ",actor," at ",Global.as_grid(actor.position),"/",actor.position," to coordinate ",coordinate,"; ignoring")
            continue

        var approach_path = actor.find_path_to(approach_position, terrain, obstacles)
        if approach_path.is_empty(): continue

        if path_to_unhaul.is_empty():
            #print("initializing unhaul to exploration path with size ",approach_path.size()," and region ",target_region)
            blackboard.set_value('unhaul_to_unexplored_path', approach_path)
            blackboard.set_value('unhaul_to_unexplored_region', target_region)
            continue

        if approach_path.size() < path_to_unhaul.size():
            #print("reducing unhaul to exploration path to size ",approach_path.size()," and region ",target_region)
            blackboard.set_value('unhaul_to_unexplored_path', approach_path)
            blackboard.set_value('unhaul_to_unexplored_region', target_region)
            continue
