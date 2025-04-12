@tool
extends ActionLeaf


func tick(actor, blackboard):
    var city_candidates = blackboard.get_value("city_candidates")

    var distances = city_candidates.keys()
    distances.sort()

    for distance in distances:

        for nearby_city in city_candidates[distance]:
            if nearby_city.my_team == actor.my_team:
                continue

            # ensure we are able to get to the city
            var found_path = actor.plan.set_path_to_city(nearby_city, blackboard.get_value("terrain"))
            if not found_path:
                continue

            blackboard.set_value("city_target", nearby_city)
            return SUCCESS

    return FAILURE
