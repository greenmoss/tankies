extends "res://common/state.gd"


func enter():
    var my_unit:Unit = select_own_unit()
    if my_unit == null: return

    var enemy_unit:Unit = select_enemy_unit(my_unit)
    if enemy_unit == null: return

    my_unit.move_toward(my_unit._path[0])
    emit_signal("next_state", "move")


# also sets path on my unit to enemy unit
func select_enemy_unit(my_unit:Unit) -> Unit:
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

    if not owner.terrain.is_point_walkable(enemy_unit.position):
        my_unit.state.force_end()
        emit_signal("next_state", "plan")
        return null

    if my_unit._path.is_empty():
        my_unit._path = owner.terrain.find_path(my_unit.position, enemy_unit.position)

    # target moved, so recalculate
    if enemy_unit.position != my_unit._path[-1]:
        my_unit._path.clear()
        emit_signal("next_state", "plan")
        return null

    if my_unit.position == my_unit._path[0]:
        my_unit._path.remove_at(0)

    # reached end of path, so recalculate
    if my_unit._path.is_empty():
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
