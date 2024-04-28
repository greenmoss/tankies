extends "res://common/state.gd"


func enter():
    var my_unit:Unit = select_own_unit()
    if my_unit == null:
        # none of my units are available
        # thus select_own_unit already emitted a signal
        return

    var enemy_unit:Unit = target_enemy_unit(my_unit)
    var enemy_city:City = target_enemy_city(my_unit)

    if enemy_unit == null:
        if enemy_city == null:
            emit_signal("next_state", "end")
            return

        # no enemy units, and we have an enemy city
        # more toward enemy city
        my_unit.move_toward(my_unit.plan.path_to_city[0])
        emit_signal("next_state", "move")
        return

    if enemy_city == null:
        my_unit.move_toward(my_unit.plan.path_to_unit[0])
        emit_signal("next_state", "move")

    # we have both a unit and a city
    # find whichever is closest
    var city_distance:int = my_unit.plan.path_to_city.size()
    var unit_distance:int = my_unit.plan.path_to_unit.size()

    # enemy city is closest, move there
    if city_distance < unit_distance:
        my_unit.move_toward(my_unit.plan.path_to_city[0])
        emit_signal("next_state", "move")
        return

    # enemy unit is closest, move there
    my_unit.move_toward(my_unit.plan.path_to_unit[0])
    emit_signal("next_state", "move")


func target_enemy_city(my_unit:Unit) -> City:
    # if we already have an un-owned target city, use that again
    if my_unit.plan.goto_city != null:
        if my_unit.plan.goto_city.my_team != my_unit.my_team:
            var found_path = my_unit.plan.set_path_to_city(my_unit.plan.goto_city, owner.terrain)
            if found_path:
                return my_unit.plan.goto_city

    var enemy_city:City = null
    var cities_by_distance:Dictionary = owner.cities.get_all_by_cardinal_distance(my_unit.position)

    var distances = cities_by_distance.keys()
    distances.sort()
    for distance in distances:
        if enemy_city != null: break

        for nearby_city in cities_by_distance[distance]:
            if nearby_city.my_team == my_unit.my_team:
                continue

            # ensure we are able to get to the city
            var found_path = my_unit.plan.set_path_to_city(nearby_city, owner.terrain)
            if not found_path:
                continue

            enemy_city = nearby_city
            break

    return enemy_city


func target_enemy_unit(my_unit:Unit) -> Unit:
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
                push_warning("nearby enemy unit ",nearby_enemy," is active, even though it is our turn")
                continue

            # ensure we are able to get to the unit
            var found_path = my_unit.plan.set_path_to_unit(nearby_enemy, owner.terrain)
            if not found_path:
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
