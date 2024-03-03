extends Node

var unit_scene : PackedScene = preload("res://unit/unit.tscn")

func are_done():
    for unit in get_children():
        if not unit.is_done(): return false
    return true

func create(team_name, coordinates):
    var new_unit = unit_scene.instantiate()
    new_unit.my_team = team_name
    new_unit.position = coordinates
    add_child(new_unit)
    return(new_unit)

func get_first() -> Area2D:
    for unit in get_children():
        if unit.is_queued_for_deletion(): continue
        return(unit)
    return(null)

func get_next() -> Area2D:
    for unit in get_children():
        if unit.is_queued_for_deletion(): continue
        if unit.has_more_moves():
            return(unit)
    # not units with moves
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
