@tool
extends ActionLeaf


func tick(actor, blackboard):
    var thoughts = blackboard.get_value("thoughts")
    if(thoughts == null):
        return FAILURE

    if(thoughts < 10):
        return FAILURE

    push_warning("unit " + actor.name + " could not figure out what to do and prematurely ended its turn")

    blackboard.set_value("move_position", null)

    return SUCCESS
