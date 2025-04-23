@tool
extends ActionLeaf


func tick(_actor, blackboard):
    var thoughts = blackboard.get_value("thoughts")
    if(thoughts == null):
        return FAILURE

    if(thoughts < 10):
        return FAILURE

    push_warning("unit " + owner.name + " could not figure out what to do and prematurely ended its turn")

    blackboard.set_value("move_position", null)

    return SUCCESS
