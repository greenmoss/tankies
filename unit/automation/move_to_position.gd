@tool
extends ActionLeaf


func tick(actor, blackboard):
    var move_position:Vector2 = blackboard.get_value("move_position")
    if move_position == null:
        return FAILURE

    actor.set_manual()
    actor.move_toward(move_position)
    return SUCCESS
