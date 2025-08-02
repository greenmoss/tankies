@tool
extends ActionLeaf


func tick(actor, blackboard):
    if blackboard.get_value("city_target") == null:
        return FAILURE

    blackboard.set_value("move_position", actor.plan.path_to_city[0])
    return SUCCESS
