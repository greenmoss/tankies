extends ActionLeaf


func tick(actor, blackboard):
    var my_units = blackboard.get_value("my_units")
    var regions = blackboard.get_value("regions")
    var terrain = blackboard.get_value("terrain")

    var hauler:Unit = null
    var path:PackedVector2Array = []
    var comparison_path = null

    for unit in my_units:
        if unit == actor: continue
        if not unit.can_haul_unit(actor): continue

        if hauler == null:
            # direct path, regardless of regions
            path = terrain.find_path(actor.position, unit.position, 'air')
            if path.is_empty(): continue

            hauler = unit
            continue

        # direct path, regardless of regions
        comparison_path = terrain.find_path(actor.position, unit.position, 'air')
        if comparison_path.size() >= path.size(): continue
        if comparison_path.is_empty(): continue

        hauler = unit
        path = comparison_path

    if path.is_empty():
        return FAILURE

    # first path portion is current position, which messes up movement
    path.remove_at(0)

    if path.is_empty():
        return FAILURE

    var next_move = path[0]

    # get path to next
    var layer_path = terrain.find_path(actor.position, next_move, actor.navigation)
    # if path within layer is 3 or more, it means we were on an untraversible diagonal
    if layer_path.size() > 2:
        blackboard.set_value("move_position", null)
        return FAILURE

    var this_region = regions.get_from_unit(actor)
    var dest_regions = regions.get_from_position(next_move)

    if this_region in dest_regions:
        blackboard.set_value("move_position", next_move)
        return SUCCESS

    # if we are diagonally next to coast, need to move one more position
    var path_neighbors = terrain.get_in_bounds_neighbors(Global.as_grid(next_move))
    var my_neighbors = terrain.get_in_bounds_neighbors(Global.as_grid(actor.position))
    var intersection = null
    for point in path_neighbors:
        if point not in my_neighbors: continue
        intersection = Global.as_position(point)
        break

    if intersection == null:
        return FAILURE

    # already next to coast, can not move any further
    var intersection_regions = regions.get_from_position(intersection)
    if this_region not in intersection_regions:
        return FAILURE

    blackboard.set_value("move_position", intersection)
    return SUCCESS
