@tool
extends ActionLeaf


func tick(actor, _blackboard):
    if actor.can_haul():
        return FAILURE

    actor.state.force_haul()
    actor.set_manual()
    return SUCCESS
