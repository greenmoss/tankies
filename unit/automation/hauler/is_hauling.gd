@tool
extends ActionLeaf


func tick(actor, blackboard):
    var empty_positions:Array[Vector2] = []

    if actor.is_hauling():
        #print("set unhaul to region 2")
        return SUCCESS

    blackboard.set_value('unhaul_to_region', null)
    blackboard.set_value("unhaul_to_region_checked", empty_positions)
    return FAILURE


