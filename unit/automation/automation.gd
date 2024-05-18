class_name BTUnitAutomation extends BeehaveTree


# Set a unique behavior tree name
# Allows us to track individual units in the BT debugger
func _enter_tree():
    name = 'BT'+owner.name


func set_cities(candidates:Dictionary):
    blackboard.set_value("city_candidates", candidates)


func set_terrain(terrain):
    blackboard.set_value("terrain", terrain)


func set_units(candidates:Dictionary):
    blackboard.set_value("unit_candidates", candidates)
