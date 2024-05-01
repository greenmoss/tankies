extends "res://common/state.gd"


func enter():
    owner.units.refill_moves()

    maybe_activate_unit()

    emit_signal("next_state", "wait")


func maybe_activate_unit():
    '''
    if all units are sleeping but one still has remaining moves
    wake up that unit
    '''

    var nearby = owner.units.get_all_by_cardinal_distance(owner.cursor.position)
    var distances = nearby.keys()
    distances.sort()

    var nearby_potential_unit:Unit = null
    var nearby_ready_unit:Unit = null

    for distance in distances:
        if nearby_ready_unit != null:
            break

        for unit in nearby[distance]:
            if not is_instance_valid(unit):
                continue

            if unit.is_queued_for_deletion():
                continue

            if unit.state.is_named('end'):
                continue

            if unit.state.is_named('sleep'):

                if nearby_potential_unit == null:
                    nearby_potential_unit = unit
                    break

                continue

            nearby_ready_unit = unit
            break

    if nearby_ready_unit == null:
        if nearby_potential_unit != null:
            nearby_potential_unit.state.current_state.awaken()
