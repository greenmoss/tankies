@tool
extends ActionLeaf


func tick(actor, blackboard):
    var my_units = blackboard.get_value("my_units")

    var hauler:Unit = null
    var path:PackedVector2Array = []
    var comparison_path = null

    for unit in my_units:
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit == actor: continue
        if not unit.can_haul_unit(actor): continue

        if hauler == null:
            path = get_path_to_hauler(unit, actor, blackboard)
            if path.is_empty(): continue

            hauler = unit
            continue

        comparison_path = get_path_to_hauler(unit, actor, blackboard)
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

    blackboard.set_value("move_position", path[0])
    return SUCCESS


func get_path_to_hauler(hauler:Unit, actor:Unit, blackboard:Blackboard) -> PackedVector2Array:
    var obstacles = blackboard.get_value("obstacles")
    var terrain = blackboard.get_value("terrain")
    var path = actor.find_path_to(hauler.position, terrain, obstacles)
    if not path.is_empty(): return path

    var grid_position = Global.as_grid(hauler.position)
    var comparison_path = null
    for neighbor in terrain.get_in_bounds_neighbors(grid_position):
        var neighbor_position = Global.as_position(neighbor)
        if path.is_empty():
            path = actor.find_path_to(neighbor_position, terrain, obstacles)
            continue

        comparison_path = actor.find_path_to(neighbor_position, terrain, obstacles)
        if comparison_path.size() >= path.size(): continue
        if comparison_path.is_empty(): continue
        path = comparison_path
    return path
