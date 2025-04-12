@tool
extends ActionLeaf
# This unit is hauling units
# Move to wherever they want to go


func tick(actor, blackboard):
    blackboard.set_value('unhaul_to_unit_path', null)
    blackboard.set_value('unhaul_to_unit_region', null)

    #print("transport ",actor," setting unhaul to unit path with moves remaining ",actor.moves_remaining," and state ",actor.state.current_state.name)

    if not actor.is_hauling(): return FAILURE

    var unit_candidates = blackboard.get_value("unit_candidates")
    var terrain = blackboard.get_value("terrain")
    var regions = blackboard.get_value("regions")

    if (unit_candidates == null) or (terrain == null):
        blackboard.set_value("unit_target", null)
        return FAILURE

    var unit:Unit = null
    for hauled_unit in actor.hauled_units:
        if hauled_unit.moves_remaining <= 0: continue
        unit = hauled_unit
        break

    if unit == null: return FAILURE

    #print("hauler ",actor," is setting unhaul to unit for ",unit)

    var path_to_unhaul:PackedVector2Array = []

    #var target_unit = null

    var target_region:Region = null
    var distances = unit_candidates.keys()
    distances.sort()
    for distance in distances:
        for nearby_enemy in unit_candidates[distance]:

            # these two can happen after a battle where the target was destroyed
            # consider the move invalid and try again
            if not is_instance_valid(nearby_enemy):
                continue
            if nearby_enemy.is_queued_for_deletion():
                continue
            #print("here3")

            # we should never see this, because we should only be moving on our turn
            if nearby_enemy.state.is_active():
                push_warning("nearby enemy unit ",nearby_enemy," is active, even though it is our turn")
                continue

            var region_with_enemy = regions.get_from_unit(nearby_enemy)
            var region_is_compatible = (unit.get_colliders() & region_with_enemy.colliders) == 0
            if not region_is_compatible: continue
            #print("unit ",nearby_enemy," region: ",region_with_enemy)

            var approach_path = terrain.find_path(actor.position, nearby_enemy.position, 'air')
            #print("air path from ",Global.as_grid(actor.position),"/",actor.position," to ",Global.as_grid(nearby_enemy.position),"/",nearby_enemy.position," is ",approach_path)
            #print("air path as grid: ",Global.array_as_grid(approach_path))

            var approach_position = region_with_enemy.get_approach_position(approach_path)
            if approach_position == Vector2.LEFT:
                push_warning("could not find air path from hauler ",actor," at ",Global.as_grid(actor.position),"/",actor.position," to unit ",nearby_enemy," at ",Global.as_grid(nearby_enemy.position),"/",nearby_enemy.position,"; ignoring unit")
                continue
            #print("intersects at approach ",approach_position)

            approach_path = terrain.find_path(actor.position, approach_position, actor.navigation)
            #print("navigable path: ",approach_path)
            #print("navigable path as grid: ",Global.array_as_grid(approach_path))

            if approach_path.is_empty(): continue

            #print("set unhaul to unit path 1")

            if path_to_unhaul.is_empty():
                path_to_unhaul = approach_path
                target_region = region_with_enemy
                #print("initializing path to unhaul with size ",path_to_unhaul.size())
                #target_unit = nearby_enemy
            #print("set unhaul to unit path 2")
            if approach_path.size() < path_to_unhaul.size():
                path_to_unhaul = approach_path
                target_region = region_with_enemy
                #print("reducing path to unhaul with size ",path_to_unhaul.size())
                #target_unit = nearby_enemy
            #print("set unhaul to unit path 3")

    # no units found that we can move toward
    if path_to_unhaul.is_empty(): return FAILURE

    blackboard.set_value('unhaul_to_unit_path', path_to_unhaul)
    blackboard.set_value('unhaul_to_unit_region', target_region)
    return SUCCESS

    ## we are at the unhaul location now, but blocked here?
    #if path_to_unhaul.size() <= 1:
    #    print("next to enemy unit ",target_unit)
    #    #unit.set_automatic()
    #    return FAILURE

    #print("moving toward enemy unit ",target_unit," to unhaul: ",path_to_unhaul[1])
    #blackboard.set_value("move_position", path_to_unhaul[1])
    #return SUCCESS
