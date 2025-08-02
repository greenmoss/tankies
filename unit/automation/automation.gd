@tool
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
    city_candidates:Dictionary,
    unit_candidates:Dictionary,
    explored:Dictionary,
    my_units:Array,
    obstacles:Obstacles,
    regions:Regions,
    terrain:Terrain):

    blackboard.set_value("city_candidates", city_candidates)
    blackboard.set_value("explored", explored)
    blackboard.set_value("my_units", my_units)
    blackboard.set_value("obstacles", obstacles)
    blackboard.set_value("regions", regions)
    blackboard.set_value("terrain", terrain)
    blackboard.set_value("unit_candidates", unit_candidates)

    var thoughts = blackboard.get_value("thoughts")
    if(thoughts == null):
        clear_thoughts()
    else:
        blackboard.set_value("thoughts", thoughts + 1)
    #print(owner.name + ' BT ' + str(blackboard.get_value("thoughts")))

    # also initialize hauled units
    # in case they unhaul
    if owner.is_hauling():
        for unit in owner.hauled_units:
            unit.automation.initialize(
                city_candidates,
                unit_candidates,
                explored,
                my_units,
                obstacles,
                regions,
                terrain,
            )

func clear_thoughts():
    blackboard.set_value("thoughts", 0)
