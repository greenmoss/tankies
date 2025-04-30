@tool
extends 'common_action_leaf.gd'
# This unit is hauling units
# Move to wherever they want to go


func tick(actor, blackboard):
    blackboard.set_value('unhaul_to_city_path', null)
    blackboard.set_value('unhaul_to_city_region', null)

    if not actor.is_hauling(): return FAILURE

    var city_candidates = blackboard.get_value("city_candidates")
    var terrain = blackboard.get_value("terrain")
    var regions = blackboard.get_value("regions")

    if (city_candidates == null) or (terrain == null):
        blackboard.set_value("unit_target", null)
        return FAILURE

    var unit = get_idle_hauled(actor)
    if unit == null: return FAILURE

    #print("hauler ",actor," is setting unhaul to city for ",unit)

    var path_to_unhaul:PackedVector2Array = []

    var target_region:Region = null
    var distances = city_candidates.keys()
    distances.sort()
    for distance in distances:
        for nearby_city in city_candidates[distance]:
            if nearby_city.team_name == actor.team_name: continue
            #print("in set unhaul to city path, looking at city ",nearby_city)

            var region_with_city:Region = null
            for region in regions.get_from_position(nearby_city.position):
                if (unit.get_colliders() & region.colliders) != 0: continue
                region_with_city = region
            if region_with_city == null: continue

            #print("city ",nearby_city," region: ",region_with_city)
          
            var approach_path = terrain.find_path(actor.position, nearby_city.position, 'air')
            #print("air path from ",Global.as_grid(actor.position),"/",actor.position," to ",Global.as_grid(nearby_city.position),"/",nearby_city.position," is ",approach_path)
            #print("air path as grid: ",Global.array_as_grid(approach_path))

            var approach_position = region_with_city.get_approach_position(approach_path)
            if approach_position == Vector2.LEFT:
                push_warning("could not find air path from hauler ",actor," at ",Global.as_grid(actor.position),"/",actor.position," to city ",nearby_city," at ",Global.as_grid(nearby_city.position),"/",nearby_city.position,"; ignoring city")
                continue
            #print("intersects at approach ",approach_position)

            approach_path = terrain.find_path(actor.position, approach_position, actor.navigation)
            #print("navigable path: ",approach_path)
            #print("navigable path as grid: ",Global.array_as_grid(approach_path))

            if approach_path.is_empty(): continue

            #print("set unhaul to city path 1")

            if path_to_unhaul.is_empty():
                path_to_unhaul = approach_path
                target_region = region_with_city
                #print("initializing path to unhaul with size ",path_to_unhaul.size())
            #print("set unhaul to city path 2")
            if approach_path.size() < path_to_unhaul.size():
                path_to_unhaul = approach_path
                target_region = region_with_city
                #print("reducing path to unhaul with size ",path_to_unhaul.size())
            #print("set unhaul to city path 3")

    # no cities found that we can move toward
    if path_to_unhaul.is_empty(): return FAILURE

    blackboard.set_value('unhaul_to_city_path', path_to_unhaul)
    blackboard.set_value('unhaul_to_city_region', target_region)
    return SUCCESS
