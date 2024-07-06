extends "res://common/state.gd"

var colliding_node:Node = null
var colliding_rid:RID = RID()
var target_city:City = null
var target_tilemap:TileMap = null
var target_units:Array[Unit] = []


func enter():
    SignalBus.unit_moved_from_position.emit(owner.unit, owner.unit.position)
    owner.unit.display.set_from_direction()

    owner.unit.ray.target_position = owner.unit.look_direction * Global.tile_size
    owner.unit.ray.force_raycast_update()

    if not owner.unit.ray.is_colliding():
        emit_signal("next_state", "move")
        return

    # get all ray collision targets
    # units can be inside other units or in cities, so ray can collide with multiple
    var target_nodes = []
    var target_rids = []
    clear_targets()
    while owner.unit.ray.is_colliding():
        colliding_node = owner.unit.ray.get_collider()
        colliding_rid = owner.unit.ray.get_collider_rid()

        if colliding_node is TileMap:
            target_tilemap = colliding_node
            target_rids.append(colliding_rid)
            owner.unit.ray.add_exception_rid(colliding_rid)
        else:
            target_nodes.append(colliding_node)
            if colliding_node.is_in_group("Cities"):
                target_city = colliding_node
            if colliding_node.is_in_group("Units"):
                target_units.append(colliding_node)
            owner.unit.ray.add_exception(colliding_node)

        owner.unit.ray.force_raycast_update()
    owner.unit.ray.clear_exceptions()

    if target_tilemap != null:
        if not target_units.is_empty():
            for target_unit in target_units:
                if target_unit.can_load(owner.unit):
                    target_unit.load_unit(owner.unit)
                    emit_signal("next_state", "move")
                    return

        owner.unit.sounds.play_denied()
        emit_signal("next_state", "idle")
        return

    if not target_units.is_empty():
        if owner.unit.my_team == target_units[0].my_team:

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
        push_warning("we should have a city here, but we don't")

    if owner.unit.my_team == target_city.my_team:
        owner.unit.in_city = target_city
        emit_signal("next_state", "move")
        return

    if not owner.unit.can_capture:
        owner.unit.sounds.play_denied()
        emit_signal("next_state", "idle")
        return

    target_units = []
    target_city = target_city
    emit_signal("next_state", "attack")
    return


# safe to invoke from any state
func clear_targets():
    target_city = null
    target_units = []
    target_tilemap = null
