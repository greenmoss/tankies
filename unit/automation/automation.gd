class_name BTUnitAutomation extends BeehaveTree


func set_cities(candidates:Dictionary):
    blackboard.set_value("city_candidates", candidates)


func set_terrain(terrain):
    blackboard.set_value("terrain", terrain)


func set_units(candidates:Dictionary):
    blackboard.set_value("unit_candidates", candidates)
