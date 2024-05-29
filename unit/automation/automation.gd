class_name BTUnitAutomation extends BeehaveTree

# since get_class() returns `Node` and we can't override it
# hold the name in a custom attribute
@warning_ignore ("unused_private_class_variable")
var _class_name = "BehaviorTree"


# Set a unique behavior tree name
# Allows us to track individual units in the BT debugger
func _enter_tree():
    name = 'BT'+owner.name
    # BT dynamic blackboard DOES NOT WORK with unit restore!
    # Thus you must assign the blackboard here:
    blackboard = owner.blackboard


func set_cities(candidates:Dictionary):
    blackboard.set_value("city_candidates", candidates)


func set_explored(explored:Dictionary):
    blackboard.set_value("explored", explored)


func set_terrain(terrain:TileMap):
    blackboard.set_value("terrain", terrain)


func set_units(candidates:Dictionary):
    blackboard.set_value("unit_candidates", candidates)
