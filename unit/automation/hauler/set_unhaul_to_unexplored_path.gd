extends 'common_action_leaf.gd'
# This unit is hauling units
# Move to wherever they want to go

@onready var region:Region = null


func tick(actor, blackboard):
    blackboard.set_value('unhaul_to_unexplored_path', null)
    blackboard.set_value('unhaul_to_unexplored_region', null)

    if not actor.is_hauling(): return FAILURE

    var unit = get_idle_hauled(actor)
    if unit == null: return FAILURE

    var regions = blackboard.get_value("regions")
    region = regions.get_from_unit(unit)
    if region == null: return FAILURE

    return SUCCESS
