extends "res://common/state.gd"


func get_all_units_under_mouse() -> Array[Unit]:
    var units:Array[Unit] = []
    for unit in owner.units_under_mouse.keys():
        if owner.units_under_mouse[unit] == false: continue
        units.append(unit)
    return units


func get_city_under_mouse() -> City:
    for city in owner.cities_under_mouse.keys():
        if owner.cities_under_mouse[city] == false: continue
        return(city)
    return null


func get_first_unit_under_mouse() -> Unit:
    var found_unit:Unit = null
    for unit in owner.units_under_mouse.keys():
        if owner.units_under_mouse[unit] == false: continue
        found_unit = unit
        break
    # with multiple units under mouse, order is unpredictable
    # so find the last unit child at current position
    # this is the unit that is visibly/"on top"
    if found_unit != null:
        found_unit = owner.get_parent().units.get_at_position(found_unit.position)[-1]
    return found_unit
