extends ActionLeaf


func tick(actor, blackboard):
    blackboard.set_value("region_from_unit", null)

    var regions = blackboard.get_value("regions")
    var unexplored_region:Region = regions.get_from_unit(actor)

    if unexplored_region == null: return FAILURE

    blackboard.set_value("region_from_unit", unexplored_region)

    return SUCCESS
