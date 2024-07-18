class_name BTUnitAutomation extends BeehaveTree

# since get_class() returns `Node` and we can't override it
# hold the name in a custom attribute
@warning_ignore ("unused_private_class_variable")
var _class_name = "BehaviorTree"


# Set a unique behavior tree name
# Allows us to track individual units in the BT debugger
func _enter_tree():
    if owner != null:
        name = 'BT'+owner.name
        # BT dynamic blackboard DOES NOT WORK with unit restore!
        # Thus you must assign the blackboard here:
        blackboard = owner.blackboard


func initialize(
    city_candidates:Dictionary, unit_candidates:Dictionary, explored:Dictionary,
    my_units:Array, regions:Regions, terrain:Terrain):

    blackboard.set_value("city_candidates", city_candidates)
    blackboard.set_value("unit_candidates", unit_candidates)
    blackboard.set_value("explored", explored)
    blackboard.set_value("my_units", my_units)
    blackboard.set_value("regions", regions)
    blackboard.set_value("terrain", terrain)
