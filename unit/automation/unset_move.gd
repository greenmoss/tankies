@tool
extends ActionLeaf


func tick(_actor, blackboard):
    blackboard.set_value("move_position", null)
    return SUCCESS
