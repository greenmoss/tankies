extends ActionLeaf


func tick(actor, blackboard):
    var move_position = blackboard.get_value("move_position")
    if move_position == null: return FAILURE

    if not actor.is_hauling(): return FAILURE

    var unhaul_path = blackboard.get_value("unhaul_to_region_closest_path")
    if unhaul_path == null: return FAILURE
    #print("hauler ",actor," moving to path ",unhaul_path)
    if unhaul_path.size() > 1: return FAILURE

    actor.set_manual()
    for hauled_unit in actor.hauled_units:
        #print("hauler ",actor," stopping to unhaul ",hauled_unit)
        hauled_unit.set_automatic()
        # TODO: figure out how to wait until unhauled units have completed
        # can not use `await`
        # it gives error `Trying to call an async function without "await"`
        #await SignalBus.unit_moved_to_position
    return SUCCESS
