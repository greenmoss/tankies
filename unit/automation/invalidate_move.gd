extends ActionLeaf


func tick(actor, blackboard):
    blackboard.set_value("move_position", null)
    return SUCCESS
