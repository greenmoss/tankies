@tool
extends ActionLeaf


func tick(_actor, blackboard):
    blackboard.set_value("unhaul_to_region_closest_path", null)
    blackboard.set_value("unhaul_to_region_closest_region", null)

    var city_path = blackboard.get_value("unhaul_to_city_path")
    var city_region = blackboard.get_value("unhaul_to_city_region")
    var city_valid = (city_region != null) and (city_path != null) and (city_path.size() > 0)

    var unexplored_path = blackboard.get_value("unhaul_to_unexplored_path")
    var unexplored_region = blackboard.get_value("unhaul_to_unexplored_region")
    var unexplored_valid = (unexplored_region != null) and (unexplored_path != null) and (unexplored_path.size() > 0)

    var unit_path = blackboard.get_value("unhaul_to_unit_path")
    var unit_region = blackboard.get_value("unhaul_to_unit_region")
    var unit_valid = (unit_region != null) and (unit_path != null) and (unit_path.size() > 0)

    var shortest = null
    var type = null

    if city_valid:
        if shortest == null:
            shortest = city_path.size()
            type = 'city'

    if unit_valid:
        if shortest == null:
            shortest = unit_path.size()
            type = 'unit'
        elif unit_path.size() < shortest:
            shortest = unit_path.size()
            type = 'unit'

    if unexplored_valid:
        if shortest == null:
            shortest = unexplored_path.size()
            type = 'unexplored'
        elif unexplored_path.size() < shortest:
            shortest = unexplored_path.size()
            type = 'unexplored'

    if type == null:
        return FAILURE

    #print("setting unhaul for ",actor," to type ",type)
    #print(blackboard.get_value('unhaul_to_'+type+'_region'))
    #print(blackboard.get_value('unhaul_to_'+type+'_path'))
    blackboard.set_value("unhaul_to_region_closest_path", blackboard.get_value('unhaul_to_'+type+'_path'))
    blackboard.set_value("unhaul_to_region_closest_region", blackboard.get_value('unhaul_to_'+type+'_region'))
    return SUCCESS
