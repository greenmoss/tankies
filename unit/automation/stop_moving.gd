@tool
extends ActionLeaf


func tick(actor, _blackboard):
    actor.state.force_end()
    actor.set_manual()
    return SUCCESS
