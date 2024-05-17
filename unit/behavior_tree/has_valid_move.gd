extends ConditionLeaf


func tick(actor, blackboard):
    if blackboard.get_value("move_position") == null:
        return FAILURE
    return SUCCESS
