@tool
extends ActionLeaf


func tick(actor, blackboard):
    var city_distance:int = actor.plan.path_to_city.size()
    var unit_distance:int = actor.plan.path_to_unit.size()

    # city is closest, so clear unit target
    if city_distance < unit_distance:
        blackboard.set_value("unit_target", null)

    # unit is closest, so clear city target
    else:
        blackboard.set_value("city_target", null)

    return SUCCESS
