extends Node
class_name Units

# we store this here so units can access it
@export var battle: Battle
var unit_scene : PackedScene = preload("res://unit/unit.tscn")


func are_done() -> bool:
    for unit in get_children():
        if not unit.state.is_done(): return false
    return true


func create(team_name, coordinates) -> Unit:
    var new_unit = unit_scene.instantiate()
    new_unit.my_team = team_name
    new_unit.position = coordinates
    add_child(new_unit)
    return(new_unit)


# this checks for cardinal distance on the map
# terrain and obstacles are *NOT* considered
func get_cardinal_closest_active(coords) -> Area2D:
    var current_closest: Area2D = null
    var current_distance: float = -1.0
    for unit in get_children():
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit.state.is_done(): continue
        if current_closest == null:
            current_closest = unit
            current_distance = coords.distance_to(unit.position)
            continue
        var new_distance: float = coords.distance_to(unit.position)
        if(new_distance < current_distance):
            current_closest = unit
            current_distance = new_distance
    return(current_closest)


func get_first() -> Area2D:
    for unit in get_children():
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        return(unit)
    return(null)


func get_next() -> Area2D:
    for unit in get_children():
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit.state.is_done(): continue
        return(unit)
    # there are no units with moves, so return nothing
    return(null)


func select_next():
    var unit : Area2D = get_next()
    if unit == null:
        return
    SignalBus.units_selected_next.emit(unit)
    await unit.select_me()


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
