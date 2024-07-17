extends ActionLeaf
# Units need hauling
# Move to them


func tick(actor, blackboard):
    var my_units = blackboard.get_value("my_units")
    blackboard.set_value("haul_unit", false)

    var hauled:Unit = null
    var path:PackedVector2Array = []
    var comparison_path = null

    for unit in my_units:
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit == actor: continue
        if not actor.can_haul_unit(unit): continue
        if unit in actor.hauled_units: continue
        if unit.is_hauled(): continue
        if unit.state.current_state.name != 'haul': continue

        if hauled == null:
            path = get_path_to_hauled(unit, actor, blackboard)
            if path.is_empty(): continue

            hauled = unit
            continue

        comparison_path = get_path_to_hauled(unit, actor, blackboard)
        if comparison_path.size() >= path.size(): continue
        if comparison_path.is_empty(): continue

        hauled = unit
        path = comparison_path

    if path.is_empty():
        return FAILURE

    # first path portion is current position, which messes up movement
    path.remove_at(0)

    if path.is_empty():
        # we have at least one unit for hauling and no more moves
        # so we must be at the coast, waiting for units
        blackboard.set_value("haul_unit", true)
        SignalBus.unit_can_haul.emit(actor)
        return FAILURE

    blackboard.set_value("move_position", path[0])

    return SUCCESS


func get_path_to_hauled(hauled:Unit, actor:Unit, blackboard:Blackboard) -> PackedVector2Array:
    var terrain = blackboard.get_value("terrain")
    var path = terrain.find_path(actor.position, hauled.position, actor.navigation)
    if not path.is_empty(): return path

    var grid_position = Global.as_grid(hauled.position)
    var comparison_path = null
    for neighbor in terrain.get_in_bounds_neighbors(grid_position):
        var neighbor_position = Global.as_position(neighbor)
        if path.is_empty():
            path = terrain.find_path(actor.position, neighbor_position, actor.navigation)
            continue

        comparison_path = terrain.find_path(actor.position, neighbor_position, actor.navigation)
        if comparison_path.size() >= path.size(): continue
        if comparison_path.is_empty(): continue
        path = comparison_path
    return path
