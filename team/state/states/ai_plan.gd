extends "res://common/state.gd"


func enter():
    var my_unit:Unit = select_own_unit()
    if my_unit == null: return

    var enemy_unit:Unit = select_enemy_unit()
    if enemy_unit == null: return

    var found_path = my_unit.plan.set_path_to_position(enemy_unit.position, owner.terrain)
    if not found_path:
        my_unit.state.force_end()
        emit_signal("next_state", "plan")
        return

    my_unit.move_toward(my_unit.plan._path[0])
    emit_signal("next_state", "move")


func select_enemy_unit() -> Unit:
    var enemy_unit:Unit = owner.enemy_units.get_first()

    # temporary until we get city attack logic
    if enemy_unit == null:
        emit_signal("next_state", "end")
        return null

    # these two can happen after a battle where the target was destroyed
    # consider the move invalid and try again
    if not is_instance_valid(enemy_unit):
        emit_signal("next_state", "plan")
        return null
    if enemy_unit.is_queued_for_deletion():
        emit_signal("next_state", "plan")
        return null

    # we should never see this, because we should only be moving on our turn
    if enemy_unit.state.is_active():
        print("WARNING: target unit ",enemy_unit," is active, even though it is our turn")
        emit_signal("next_state", "plan")
        return null

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
