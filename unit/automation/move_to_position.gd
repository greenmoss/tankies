@tool
extends ActionLeaf


func tick(actor, blackboard):
    var move_position = blackboard.get_value("move_position")
    if move_position == null:
        return FAILURE

    if move_position == actor.position:
        return FAILURE

    if move_position in actor.state.block.get_positions():
        return FAILURE
    #print("moving to position ",move_position," with blocked looks ",actor.state.block.get_positions())

    actor.set_manual()
    actor.move_toward(move_position)
    return SUCCESS
