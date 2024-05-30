extends "res://common/state.gd"


func get_first_unit_under_mouse() -> Unit:
    for unit in owner.units_under_mouse.keys():
        if owner.units_under_mouse[unit] == false: continue
        return(unit)
    return null
