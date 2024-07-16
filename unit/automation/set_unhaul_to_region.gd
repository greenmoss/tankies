extends ActionLeaf


func tick(actor, blackboard):
    var empty_positions:Array[Vector2] = []

    var path_to_unhaul:PackedVector2Array = []
    blackboard.set_value('unhaul_to_region_path', path_to_unhaul)

    if not actor.is_hauling():
        blackboard.set_value('unhaul_to_region', null)
        blackboard.set_value("unhaul_to_region_checked", empty_positions)
        #print("** at no hauled for unit ",actor,", checked is ",blackboard.get_value("unhaul_to_region_checked"))
        return FAILURE

    var terrain = blackboard.get_value("terrain")
    if terrain == null: return FAILURE

    set_closest(actor, blackboard)

    var closest_path = blackboard.get_value("unhaul_to_region_closest_path")
    var closest_region = blackboard.get_value("unhaul_to_region_closest_region")

    if (closest_path == null) or (closest_region == null): return FAILURE

    var unhaul_to_region:Region = blackboard.get_value('unhaul_to_region')
    if unhaul_to_region != closest_region:
        unhaul_to_region = closest_region
        blackboard.set_value('unhaul_to_region', unhaul_to_region)
        blackboard.set_value("unhaul_to_region_checked", empty_positions)
        #print("** at new region ",unhaul_to_region,", checked is ",blackboard.get_value("unhaul_to_region_checked"))

    #print("hauler ",actor," is setting unhaul to region ",closest_region)
    #print("unhaul to path: ",Global.array_as_grid(closest_path))

    var region_approach_position = closest_region.get_approach_position(closest_path)
    #print("approach point: ",region_approach_position)

    if region_approach_position == Vector2.LEFT: return FAILURE

    var unhaul_to_region_checked = blackboard.get_value('unhaul_to_region_checked')

    if region_approach_position not in unhaul_to_region_checked:
        #print("trying unload at new position ",region_approach_position)

        unhaul_to_region_checked.append(region_approach_position)
        blackboard.set_value('unhaul_to_region_checked', unhaul_to_region_checked)

        #print("** at check position ",region_approach_position,", checked is ",blackboard.get_value("unhaul_to_region_checked"))

        #print("trying to unhaul in region ",unhaul_to_region," with checked positions ",unhaul_to_region_checked)

        #var path_to_unhaul:PackedVector2Array = []
        for hauled_unit in actor.hauled_units:
            hauled_unit.set_automatic()

        return SUCCESS

    var retry_positions = unhaul_to_region.get_approach_neighbors(Global.as_grid(region_approach_position))
    #print("moving near position ",region_approach_position," to unload; checking positions: ",retry_positions)

    for retry_position in retry_positions:
        var approach_path = terrain.find_path(actor.position, Global.as_position(retry_position), actor.navigation)
        if path_to_unhaul.is_empty():
            path_to_unhaul = approach_path
        if approach_path.size() < path_to_unhaul.size():
            path_to_unhaul = approach_path

    if path_to_unhaul.is_empty():
        return FAILURE

    #print("path to new unload position : ",path_to_unhaul)
    #print("path as grid: ",Global.array_as_grid(path_to_unhaul))
    blackboard.set_value('unhaul_to_region_path', path_to_unhaul)
    return SUCCESS


func set_closest(actor, blackboard):
    blackboard.set_value("unhaul_to_region_closest_path", null)
    blackboard.set_value("unhaul_to_region_closest_region", null)

    var city_path = blackboard.get_value("unhaul_to_city_path")
    var city_region = blackboard.get_value("unhaul_to_city_region")
    var city_valid = (city_region != null) and (city_path != null)

    var unit_path = blackboard.get_value("unhaul_to_unit_path")
    var unit_region = blackboard.get_value("unhaul_to_unit_region")
    var unit_valid = (unit_region != null) and (unit_path != null)

    #print("at set unhaul for unit ",actor," to closest target")

    if city_valid:
        if unit_valid:
            var unit_path_shorter = (unit_path.size() < city_path.size())

            if unit_path_shorter:
                blackboard.set_value("unhaul_to_region_closest_path", unit_path)
                blackboard.set_value("unhaul_to_region_closest_region", unit_region)

            else: # city path shorter
                blackboard.set_value("unhaul_to_region_closest_path", city_path)
                blackboard.set_value("unhaul_to_region_closest_region", city_region)

        else: # unit invalid
            blackboard.set_value("unhaul_to_region_closest_path", city_path)
            blackboard.set_value("unhaul_to_region_closest_region", city_region)

    else: # city invalid

        if unit_valid:
            blackboard.set_value("unhaul_to_region_closest_path", unit_path)
            blackboard.set_value("unhaul_to_region_closest_region", unit_region)

        else: # unit invalid
            pass
