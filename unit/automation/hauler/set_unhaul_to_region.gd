extends ActionLeaf

var current_region:Region = null


func tick(actor, blackboard):
    var empty_positions:Array[Vector2] = []

    #print("set unhaul to region 4")

    var closest_path = blackboard.get_value("unhaul_to_region_closest_path")
    var closest_region = blackboard.get_value("unhaul_to_region_closest_region")

    if (closest_path == null) or (closest_region == null): return FAILURE
    #print("set unhaul to region 5")

    var unhaul_to_region:Region = current_region
    if unhaul_to_region != closest_region:
        unhaul_to_region = closest_region
        current_region = unhaul_to_region
        blackboard.set_value("unhaul_to_region_checked", empty_positions)

    var region_approach_position = closest_region.get_approach_position(closest_path)

    if region_approach_position == Vector2.LEFT: return FAILURE
    #print("set unhaul to region 6, region_approach_position: ", region_approach_position,"; closest_region: ",closest_region)
    #print("set unhaul to region 6")

    var unhaul_to_region_checked = blackboard.get_value('unhaul_to_region_checked')

    if region_approach_position not in unhaul_to_region_checked:

        unhaul_to_region_checked.append(region_approach_position)
        blackboard.set_value('unhaul_to_region_checked', unhaul_to_region_checked)

        return SUCCESS
    #print("set unhaul to region 7")

    var retry_positions = unhaul_to_region.get_approach_neighbors(Global.as_grid(region_approach_position))
    var path_to_unhaul = blackboard.get_value("unhaul_to_region_path")

    var terrain = blackboard.get_value("terrain")
    if terrain == null: return FAILURE
    for retry_position in retry_positions:
        var approach_path = terrain.find_path(actor.position, Global.as_position(retry_position), actor.navigation)
        if path_to_unhaul.is_empty():
            path_to_unhaul = approach_path
        if approach_path.size() < path_to_unhaul.size():
            path_to_unhaul = approach_path

    if path_to_unhaul.is_empty():
        return FAILURE
    #print("set unhaul to region 8")

    blackboard.set_value('unhaul_to_region_path', path_to_unhaul)
    return SUCCESS
