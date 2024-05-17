extends ConditionLeaf


func tick(actor, blackboard):
    if blackboard.get_value("city_target") == null:
        return FAILURE

    if blackboard.get_value("unit_target") == null:
        return FAILURE

    var city_distance:int = actor.plan.path_to_city.size()
    var unit_distance:int = actor.plan.path_to_unit.size()

    # enemy city is closest, move there
    if city_distance < unit_distance:
        blackboard.set_value("move_position", actor.plan.path_to_city[0])
    else:
        blackboard.set_value("move_position", actor.plan.path_to_unit[0])

    return SUCCESS
