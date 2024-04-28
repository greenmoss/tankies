extends "res://common/state.gd"


func enter():
    var my_unit:Unit = select_own_unit()
    if my_unit == null: return

    var enemy_unit:Unit = select_enemy_unit(my_unit)
    if enemy_unit == null:
        emit_signal("next_state", "end")
        return

    var enemy_city:City = select_enemy_city()

    var found_path = my_unit.plan.set_path_to_position(enemy_unit.position, owner.terrain)
    if not found_path:
        my_unit.state.force_end()
        emit_signal("next_state", "plan")
        return

    my_unit.move_toward(my_unit.plan._path[0])
    emit_signal("next_state", "move")


func select_enemy_city() -> City:
    return null


func select_enemy_unit(my_unit:Unit) -> Unit:
    #var enemy_unit:Unit = owner.enemy_units.get_first()
    var enemy_unit:Unit = null

    var enemy_units_by_distance:Dictionary = owner.enemy_units.get_all_by_cardinal_distance(my_unit.position)

    var distances = enemy_units_by_distance.keys()
    distances.sort()
    for distance in distances:
        if enemy_unit != null: break

        for nearby_enemy in enemy_units_by_distance[distance]:

            # these two can happen after a battle where the target was destroyed
            # consider the move invalid and try again
            if not is_instance_valid(nearby_enemy):
                continue
            if nearby_enemy.is_queued_for_deletion():
                continue

            # we should never see this, because we should only be moving on our turn
            if nearby_enemy.state.is_active():
                print("WARNING: nearby enemy unit ",nearby_enemy," is active, even though it is our turn")
                continue

            # ensure we are able to get to the unit
            var path = owner.terrain.find_path(my_unit.position, nearby_enemy.position)
            if path.is_empty():
                continue

            enemy_unit = nearby_enemy
            break

    return enemy_unit


func select_own_unit() -> Unit:

    var my_unit = owner.units.get_next()

    # no active units remain, so we are done
    if my_unit == null:
        emit_signal("next_state", "end")
        return null

    if not is_instance_valid(my_unit):
        emit_signal("next_state", "plan")
        return null

    if my_unit.is_queued_for_deletion():
        emit_signal("next_state", "plan")
        return null

    if my_unit.state.is_done():
        emit_signal("next_state", "plan")
        return null

    if my_unit.state.is_active():
        emit_signal("next_state", "move")
        return null

    return my_unit
