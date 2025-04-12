@tool
extends ActionLeaf


func tick(actor, blackboard):
    var my_units = blackboard.get_value("my_units")
    var terrain = blackboard.get_value("terrain")

    var haulers_by_position = {}

    for unit in my_units:
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit == actor: continue
        if not unit.can_haul_unit(actor): continue

        haulers_by_position[unit.position] = unit

    if haulers_by_position.is_empty(): return FAILURE

    var grid_position = Global.as_grid(actor.position)
    var neighbor_haulers:Array[Unit] = []
    for neighbor in terrain.get_in_bounds_neighbors(grid_position):
        var neighbor_position = Global.as_position(neighbor)
        if not neighbor_position in haulers_by_position.keys(): continue
        neighbor_haulers.append(haulers_by_position[neighbor_position])

    if neighbor_haulers.is_empty(): return FAILURE

    var max_hauler = neighbor_haulers[0]
    for hauler in neighbor_haulers:
        if hauler.hauled_units.size() <= max_hauler.hauled_units.size(): continue
        max_hauler = hauler

    blackboard.set_value("move_position", max_hauler.position)

    return SUCCESS
