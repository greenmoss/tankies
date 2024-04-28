extends Node
class_name Units

# we store this here so units can access it
@export var battle: Battle
var unit_scene : PackedScene = preload("res://unit/unit.tscn")


func are_done() -> bool:
    for unit in get_children():
        if not unit.state.is_done(): return false
    return true


func are_active() -> bool:
    for unit in get_children():
        if unit.state.is_active(): return true
    return false


func create(team_name, position:Vector2) -> Unit:
    var new_unit = unit_scene.instantiate()
    new_unit.my_team = team_name
    new_unit.position = position
    add_child(new_unit)
    return(new_unit)


# this checks for cardinal distance on the map
# terrain and obstacles are *NOT* considered
func get_all_by_cardinal_distance(position:Vector2) -> Dictionary:
    var distance_map = {}
    for unit in get_children():
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        var distance: float = position.distance_to(unit.position)
        if distance not in distance_map:
            distance_map[distance] = []
        distance_map[distance].append(unit)
    return(distance_map)


func get_cardinal_closest_active(position:Vector2) -> Unit:
    var nearby = get_all_by_cardinal_distance(position)
    var distances = nearby.keys()
    distances.sort()

    for distance in distances:
        for unit in nearby[distance]:
            if not is_instance_valid(unit):
                continue

            if unit.is_queued_for_deletion():
                continue

            if unit.state.is_done():
                continue

            return unit

    return null


func get_first() -> Unit:
    for unit in get_children():
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        return(unit)
    return(null)


func get_next() -> Unit:
    for unit in get_children():
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit.state.is_done(): continue
        return(unit)
    # there are no units with moves, so return nothing
    return(null)


func select_next():
    var unit:Unit = get_next()
    if unit == null:
        return
    SignalBus.units_selected_next.emit(unit)
    unit.select_me()


func refill_moves():
    for unit in get_children():
        await unit.refill_moves()


# team object saves units
# func save()


func restore(saved_units):
    for unit in get_children():
        self.remove_child(unit)
        unit.queue_free()

    if(saved_units.is_empty()): return

    var unit_template = unit_scene.instantiate()

    for saved_unit in saved_units:
        var unit = unit_template.duplicate()
        saved_unit.restore(unit)
        add_child(unit)

    unit_template.queue_free()
