extends "res://common/state.gd"

var colliding_node:Node = null
var colliding_rid:RID = RID()
var target_city:City = null
var target_tilemap:TileMap = null
var target_units:Array[Unit] = []


func enter() -> void:
    SignalBus.unit_moved_from_position.emit(owner.unit, owner.unit.position)
    owner.unit.display.set_from_direction()

    owner.unit.ray.target_position = owner.unit.look_direction * Global.tile_size
    owner.unit.ray.force_raycast_update()

    set_ray_targets()

    if handled_unhaul(): return
    if handled_clear(): return
    if handled_tile_blocker(): return
    if handled_target_unit(): return
    if handled_target_city(): return


func handled_friendly_target_city() -> bool:
    if not targets_city(): return false

    if owner.unit.my_team == target_city.my_team:
        owner.unit.in_city = target_city
        emit_signal("next_state", "move")
        return true

    return false


func handled_friendly_target_unit() -> bool:
    if not targets_units(): return false

    if owner.unit.my_team == target_units[0].my_team:

        if handled_friendly_target_city(): return true

        emit_signal("next_state", "move")
        return true

    return false


func handled_target_city() -> bool:
    if not targets_city(): return false

    if handled_friendly_target_city():
        return true

    if not owner.unit.can_capture:
        owner.unit.sounds.play_denied()
        emit_signal("next_state", "idle")
        return true

    target_units = []
    emit_signal("next_state", "attack")
    return true


func handled_target_unit() -> bool:
    if not targets_units(): return false

    if handled_friendly_target_unit(): return true

    # we first have to destroy any enemy units, then check again
    target_city = null
    emit_signal("next_state", "attack")
    return true


func handled_tile_blocker() -> bool:
    if not targets_tile(): return false

    if handled_haul(): return true

    owner.unit.sounds.play_denied()
    emit_signal("next_state", "idle")
    return true


func handled_clear() -> bool:
    if targets_anything(): return false

    emit_signal("next_state", "move")
    return true


func handled_haul() -> bool:
    for target_unit in target_units:
        if target_unit.can_haul(owner.unit):
            target_unit.haul_unit(owner.unit)
            emit_signal("next_state", "move")
            return true

    return false


func handled_unhaul() -> bool:
    if not owner.unit.is_hauled(): return false

    if handled_clear():
        owner.unit.set_unhauled()
        return true

    if handled_friendly_target_city():
        owner.unit.set_unhauled()
        return true

    if handled_friendly_target_unit():
        owner.unit.set_unhauled()
        return true

    owner.unit.sounds.play_denied()
    emit_signal("next_state", "haul")
    return true


func targets_anything() -> bool:
    return targets_city() or targets_tile() or targets_units()


func targets_city() -> bool:
    return target_city != null


func targets_collider() -> bool:
    return owner.unit.ray.is_colliding()


func targets_tile() -> bool:
    return target_tilemap != null


func targets_units() -> bool:
    return target_units.size() > 0


func set_ray_targets() -> void:
    target_city = null
    target_units = []
    target_tilemap = null

    # get all ray collision targets
    # units can be inside other units or in cities, so ray can collide with multiple
    var target_nodes = []
    var target_rids = []
    while targets_collider():
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
