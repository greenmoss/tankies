extends "res://common/state.gd"


func enter():
    var my_unit:Unit = owner.units.get_next()

    # no active units remain, so we are done
    if my_unit == null:
        emit_signal("next_state", "end")
        return

    # unit is being deleted, so try again
    if not is_instance_valid(my_unit):
        emit_signal("next_state", "plan")
        return
    if my_unit.is_queued_for_deletion():
        emit_signal("next_state", "plan")
        return

    # unit finished moving, so try again
    if my_unit.state.is_done():
        emit_signal("next_state", "plan")
        return

    # unit is moving, so switch to team move state
    if my_unit.state.is_active():
        emit_signal("next_state", "move")
        return

    my_unit.automation.set_cities( owner.cities.get_explored_by_cardinal_distance(my_unit.position, owner.vision) )
    my_unit.automation.set_enemy_units( owner.enemy_units.get_all_by_cardinal_distance(my_unit.position, owner.vision) )
    my_unit.automation.set_my_units( owner.units.get_all_valid() )
    my_unit.automation.set_explored( owner.vision.explored )
    my_unit.automation.set_regions( owner.regions )
    my_unit.automation.set_terrain( owner.terrain )

    # enable unit automation
    my_unit.set_automatic()
    # wait until the unit is done moving
    emit_signal("next_state", "move")
