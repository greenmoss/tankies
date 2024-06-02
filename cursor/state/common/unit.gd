extends "res://common/state.gd"


func get_first_city_under_mouse() -> City:
    for city in owner.cities_under_mouse.keys():
        if owner.cities_under_mouse[city] == false: continue
        return(city)
    return null


func get_first_unit_under_mouse() -> Unit:
    for unit in owner.units_under_mouse.keys():
        if owner.units_under_mouse[unit] == false: continue
        return(unit)
    return null
