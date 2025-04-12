@tool
extends ActionLeaf


func tick(actor, blackboard):
    if blackboard.get_value("unit_target") == null:
        return FAILURE

    blackboard.set_value("move_position", actor.plan.path_to_unit[0])
    return SUCCESS
