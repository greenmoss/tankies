extends ConditionLeaf


func tick(actor, blackboard):
    if blackboard.get_value("city_target") == null:
        return FAILURE
    return SUCCESS
