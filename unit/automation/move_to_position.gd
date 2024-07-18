extends ActionLeaf


func tick(actor, blackboard):
    var move_position = blackboard.get_value("move_position")
    if move_position == null:
        return FAILURE

    if move_position == actor.position:
        return FAILURE

    actor.set_manual()
    actor.move_toward(move_position)
    return SUCCESS
