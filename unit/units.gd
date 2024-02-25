extends Node

var unit_scene : PackedScene = preload("res://unit/unit.tscn")

func are_done():
    for unit in get_children():
        if unit.has_more_moves(): return false
    return true

func create(team_name, coordinates):
    var new_unit = unit_scene.instantiate()
    new_unit.my_team = team_name
    new_unit.position = coordinates
    add_child(new_unit)
    return(new_unit)

func get_next() -> Area2D:
    for unit in get_children():
        if unit.has_more_moves():
            return(unit)
    # not units with moves
    return(null)

func select_next():
    var unit : Area2D = get_next()
    if unit == null:
        return
    SignalBus.units_selected_next.emit(unit)
    unit.select_me()

func refill_moves():
    for unit in get_children():
        unit.refill_moves()
