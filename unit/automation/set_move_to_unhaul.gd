extends ActionLeaf
# This unit is hauling units
# Move to wherever they want to go


func tick(actor, blackboard):
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

    print("hauler ",actor," is checking move to unhaul for unit ",unit)

    var path_to_unhaul:PackedVector2Array = []

    var target_unit = null

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

            if path_to_unhaul.is_empty():
                path_to_unhaul = approach_path
                target_unit = nearby_enemy
            if approach_path.size() < path_to_unhaul.size():
                path_to_unhaul = approach_path
                target_unit = nearby_enemy

    # no units found that we can move toward
    if path_to_unhaul.is_empty(): return FAILURE

    # we are at the unhaul location now, but blocked here?
    if path_to_unhaul.size() <= 1:
        print("next to enemy unit ",target_unit)
        #unit.set_automatic()
        return FAILURE

    print("moving toward enemy unit ",target_unit," to unhaul: ",path_to_unhaul[1])
    blackboard.set_value("move_position", path_to_unhaul[1])
    return SUCCESS

            #var enemy_neighbor_points = terrain.get_in_bounds_neighbors(Global.as_grid(nearby_enemy.position))
            #var enemy_approaches = []
            #for point in enemy_neighbor_points:
            #    if not point in region_with_enemy.approaches: continue
            #    enemy_approaches.append(point)
            #print("enemy approach points: ",enemy_approaches)

            #if enemy_approaches.is_empty(): continue

            #var adjacent_approaches:Array[Vector2i] = []
            #for approach_point in enemy_approaches:
            #    for adjacent_point in region_with_enemy.get_approach_neighbors(approach_point):
            #        if adjacent_point in enemy_approaches: continue
            #        if adjacent_point in adjacent_approaches: continue
            #        adjacent_approaches.append(adjacent_point)
            #print("adjacent approach points: ",adjacent_approaches)

            #for landing_point in adjacent_approaches:
            #    var approach_path = terrain.find_coordinate_path(Global.as_grid(actor.position), landing_point, actor.navigation)
            #    if path_to_unload.is_empty():
            #        path_to_unload = approach_path
            #    if path_to_unload.size() < approach_path.size():
            #        path_to_unload = approach_path
            #    print("path from ",Global.as_grid(actor.position)," to adjacent point ",landing_point," is ",Global.array_as_grid(approach_path))
    #unit.automation.initialize(
    #    blackboard.get_value("city_candidates"),
    #    blackboard.get_value("unit_candidates"),
    #    blackboard.get_value("explored"),
    #    blackboard.get_value("my_units"),
    #    blackboard.get_value("regions"),
    #    blackboard.get_value("terrain"),
    #    )
    #unit.set_automatic()

#    return FAILURE

#    var my_units = blackboard.get_value("my_units")
#    blackboard.set_value("haul_unit", false)
#
#    var hauled:Unit = null
#    var path:PackedVector2Array = []
#    var comparison_path = null
#
#    for unit in my_units:
#        if unit == actor: continue
#        if not actor.can_haul_unit(unit): continue
#        if unit in actor.hauled_units: continue
#        if unit.is_hauled(): continue
#        if unit.state.current_state.name != 'haul': continue
#
#        if hauled == null:
#            path = get_path_to_hauled(unit, actor, blackboard)
#            if path.is_empty(): continue
#
#            hauled = unit
#            continue
#
#        comparison_path = get_path_to_hauled(unit, actor, blackboard)
#        if comparison_path.size() >= path.size(): continue
#        if comparison_path.is_empty(): continue
#
#        hauled = unit
#        path = comparison_path
#
#    if path.is_empty():
#        return FAILURE
#
#    # first path portion is current position, which messes up movement
#    path.remove_at(0)
#
#    if path.is_empty():
#        # we have at least one unit for hauling and no more moves
#        # so we must be at the coast, waiting for units
#        blackboard.set_value("haul_unit", true)
#        SignalBus.unit_can_haul.emit(actor)
#        return FAILURE
#
#    blackboard.set_value("move_position", path[0])
#
#    return SUCCESS


#func get_path_to_hauled(hauled:Unit, actor:Unit, blackboard:Blackboard) -> PackedVector2Array:
#    var terrain = blackboard.get_value("terrain")
#    var path = terrain.find_path(actor.position, hauled.position, actor.navigation)
#    if not path.is_empty(): return path
#
#    var grid_position = Global.as_grid(hauled.position)
#    var comparison_path = null
#    for neighbor in terrain.get_in_bounds_neighbors(grid_position):
#        var neighbor_position = Global.as_position(neighbor)
#        if path.is_empty():
#            path = terrain.find_path(actor.position, neighbor_position, actor.navigation)
#            continue
#
#        comparison_path = terrain.find_path(actor.position, neighbor_position, actor.navigation)
#        if comparison_path.size() >= path.size(): continue
#        if comparison_path.is_empty(): continue
#        path = comparison_path
#    return path
