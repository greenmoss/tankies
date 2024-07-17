extends ActionLeaf


func tick(actor, blackboard):
    var region_from_unit = blackboard.get_value("region_from_unit")
    if region_from_unit != null: return FAILURE

    var regions = blackboard.get_value("regions")
    if not actor.is_hauled(): return FAILURE

    var terrain = blackboard.get_value("terrain")
    if terrain == null: return FAILURE

    for neighbor in terrain.get_in_bounds_neighbors(Global.as_grid(actor.position)):
        #print("unit ",actor," point ",Global.as_grid(actor.position)," neighbor point: ",neighbor)
        for region in regions.get_from_point(neighbor):
            if not region.compatible_with(actor): continue
            #print("point is compatible with region ",region)
            blackboard.set_value("region_from_unit", region)
            return SUCCESS

    #if unexplored_region == null: return FAILURE

    #blackboard.set_value("region_from_unit", unexplored_region)

    return FAILURE
    #return SUCCESS
