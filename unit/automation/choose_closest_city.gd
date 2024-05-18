extends ActionLeaf


func tick(actor, blackboard):
    blackboard.set_value("move_position", actor.plan.path_to_city[0])
    return SUCCESS
