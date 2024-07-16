extends ActionLeaf
# Units need hauling
# Move to them


func tick(_actor, blackboard):
    var unhaul_to_region_path = blackboard.get_value("unhaul_to_region_path")
    if (unhaul_to_region_path != null) and (unhaul_to_region_path.size() > 1):
        #print("moving toward region approach to unhaul: ",Global.as_grid(unhaul_to_region_path[1]))
        blackboard.set_value("move_position", unhaul_to_region_path[1])
        return SUCCESS

    return FAILURE
#    var unhaul_to_unit_path = blackboard.get_value("unhaul_to_unit_path")
#    if unhaul_to_unit_path == null: return FAILURE
#    if unhaul_to_unit_path.size() < 2: return FAILURE
#
#    #print("moving toward enemy unit to unhaul: ",Global.as_grid(unhaul_to_unit_path[1]))
#    blackboard.set_value("move_position", unhaul_to_unit_path[1])
#    return SUCCESS
