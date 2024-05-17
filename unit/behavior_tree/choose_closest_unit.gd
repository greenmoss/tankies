extends ActionLeaf


func tick(actor, blackboard):
    blackboard.set_value("move_position", actor.plan.path_to_unit[0])
    return SUCCESS
