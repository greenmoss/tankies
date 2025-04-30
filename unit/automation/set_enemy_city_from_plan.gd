@tool
extends ActionLeaf


func tick(actor, blackboard):
    if actor.plan.goto_city == null: return FAILURE

    if actor.plan.goto_city.team_name != actor.team_name: return FAILURE

    var found_path = actor.plan.set_path_to_city(actor.plan.goto_city, blackboard.get_value("terrain"))

    if not found_path: return FAILURE

    blackboard.set_value("city_target", actor.plan.goto_city)
    return SUCCESS
