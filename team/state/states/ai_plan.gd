extends "res://common/state.gd"


func enter():
    var my_unit:Unit = owner.units.get_next()

    # no active units remain, so we are done
    if my_unit == null:
        emit_signal("next_state", "end")
        return

    if not is_instance_valid(my_unit):
        emit_signal("next_state", "plan")
        return

    if my_unit.is_queued_for_deletion():
        emit_signal("next_state", "plan")
        return

    if my_unit.state.is_done():
        emit_signal("next_state", "plan")
        return

    if my_unit.state.is_active():
        emit_signal("next_state", "move")
        return

    # TODO: make new `get_visible_by_cardinal_distance`?
    my_unit.automation.set_cities( owner.cities.get_all_by_cardinal_distance(my_unit.position) )
    my_unit.automation.set_units( owner.enemy_units.get_all_by_cardinal_distance(my_unit.position) )
    # TODO: set exploration candidates, for example
    #my_unit.automation.set_obscured( owner.vision.obscured )
    my_unit.automation.set_terrain( owner.terrain )

    # enable unit automation
    my_unit.set_automatic()
    # wait until the unit is done moving
    emit_signal("next_state", "move")
