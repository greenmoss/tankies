extends "res://common/state.gd"

func enter():
    owner.icon.set_from_direction()

    owner.ray.target_position = owner.look_direction * Global.tile_size
    owner.ray.force_raycast_update()

    if not owner.ray.is_colliding():
        emit_signal("next_state", "move")
        return

    # get all ray collision targets
    # units can be inside other units or in cities, so ray can collide with multiple
    # technique from https://forum.godotengine.org/t/27326
    var targets = []
    while owner.ray.is_colliding():
        var target = owner.ray.get_collider()
        targets.append(target)

        if target is TileMap:
            owner.sounds.play_denied()
            emit_signal("next_state", "idle")
            return

        owner.ray.add_exception(target)
        owner.ray.force_raycast_update()

    var target_city:City = null
    var target_unit:Unit = null
    for target in targets:
        owner.ray.remove_exception(target)
        if target.is_in_group("Cities"): target_city = target
        if target.is_in_group("Units"): target_unit = target

    if target_unit != null:
        if owner.my_team == target_unit.my_team:

            # If one of our units in the city, the city must already belong to us
            # So it is safe to assume we can move into the city
            if target_city != null:
                owner.in_city = target_city

            emit_signal("next_state", "move")
            return

        # it does not matter if this would move us into a city
        # we first have to destroy any enemy units, then check again
        owner.target_unit = target_unit
        emit_signal("next_state", "attack")
        return

    if target_city == null:
        print("WARNING: we should have a city here, but we don't; ray collision targets: ",targets)

    if owner.my_team == target_city.my_team:
        owner.in_city = target_city
        emit_signal("next_state", "move")
        return

    owner.target_city = target_city
    emit_signal("next_state", "attack")
    return
