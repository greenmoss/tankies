extends "res://common/state.gd"

var target_city:City = null
var target_unit:Unit = null


func enter():
    owner.unit.icon.set_from_direction()
    clear_targets()

    owner.unit.ray.target_position = owner.unit.look_direction * Global.tile_size
    owner.unit.ray.force_raycast_update()

    if not owner.unit.ray.is_colliding():
        emit_signal("next_state", "move")
        return

    # get all ray collision targets
    # units can be inside other units or in cities, so ray can collide with multiple
    # technique from https://forum.godotengine.org/t/27326
    var targets = []
    while owner.unit.ray.is_colliding():
        var target = owner.unit.ray.get_collider()
        targets.append(target)

        if target is TileMap:
            owner.unit.sounds.play_denied()
            emit_signal("next_state", "idle")
            return

        owner.unit.ray.add_exception(target)
        owner.unit.ray.force_raycast_update()

    target_city = null
    target_unit = null
    for target in targets:
        owner.unit.ray.remove_exception(target)
        if target.is_in_group("Cities"): target_city = target
        if target.is_in_group("Units"): target_unit = target

    if target_unit != null:
        if owner.unit.my_team == target_unit.my_team:

            # If one of our units in the city, the city must already belong to us
            # So it is safe to assume we can move into the city
            if target_city != null:
                owner.unit.in_city = target_city

            emit_signal("next_state", "move")
            return

        # we first have to destroy any enemy units, then check again
        target_city = null
        emit_signal("next_state", "attack")
        return

    if target_city == null:
        push_warning("we should have a city here, but we don't; ray collision targets: ",targets)

    if owner.unit.my_team == target_city.my_team:
        owner.unit.in_city = target_city
        emit_signal("next_state", "move")
        return

    if not owner.unit.can_capture:
        owner.unit.sounds.play_denied()
        emit_signal("next_state", "idle")
        return

    target_unit = null
    target_city = target_city
    emit_signal("next_state", "attack")
    return


# safe to invoke from any state
func clear_targets():
    target_city = null
    target_unit = null
