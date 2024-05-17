extends ConditionLeaf


func tick(actor, blackboard):
    if blackboard.get_value("unit_target") == null:
        return FAILURE
    return SUCCESS
