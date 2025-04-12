@tool
extends ConditionLeaf


func tick(_actor, blackboard):
    if blackboard.get_value("move_position") == null:
        return FAILURE
    return SUCCESS
