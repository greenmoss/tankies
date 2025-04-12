@tool
extends ActionLeaf


func tick(_actor, blackboard):
    var thoughts = blackboard.get_value("thoughts")
    if(thoughts == null):
        return FAILURE

    if(thoughts < 10):
        return FAILURE

    push_warning("unit " + owner.name + " thought too much and became confused")

    blackboard.set_value("move_position", null)
    return SUCCESS
