extends ActionLeaf


func tick(actor, blackboard):
    var city_candidates = blackboard.get_value("city_candidates")
    var terrain = blackboard.get_value("terrain")

    if (city_candidates == null) or (terrain == null):
        blackboard.set_value("city_target", null)
        return SUCCESS

    if actor.plan.goto_city != null:
        if actor.plan.goto_city.my_team != actor.my_team:
            var found_path = actor.plan.set_path_to_city(actor.plan.goto_city, blackboard.get_value("terrain"))
            if found_path:
                blackboard.set_value("city_target", actor.plan.goto_city)
                return SUCCESS

    var distances = city_candidates.keys()
    distances.sort()

    for distance in distances:

        for nearby_city in city_candidates[distance]:
            if nearby_city.my_team == actor.my_team:
                continue

            # ensure we are able to get to the city
            var found_path = actor.plan.set_path_to_city(nearby_city, terrain)
            if not found_path:
                continue

            blackboard.set_value("city_target", nearby_city)
            return SUCCESS

    blackboard.set_value("city_target", null)
    return SUCCESS

