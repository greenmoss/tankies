@tool
extends ActionLeaf
# Units need to be unhauled
# Move to unhaul them


func tick(_actor, blackboard):
    var unhaul_to_region_path = blackboard.get_value("unhaul_to_region_path")
    #print("unit ",actor," at position ",Global.as_grid(actor.position)," set move to unhaul on path ",Global.array_as_grid(unhaul_to_region_path))

    if (unhaul_to_region_path != null) and (unhaul_to_region_path.size() > 1):
        #print("moving toward region approach to unhaul: ",Global.as_grid(unhaul_to_region_path[1]))
        blackboard.set_value("move_position", unhaul_to_region_path[1])
        return SUCCESS

    return FAILURE
