extends ConditionLeaf


func tick(_actor, blackboard):
    if blackboard.get_value("unit_target") == null:
        return FAILURE
    return SUCCESS
