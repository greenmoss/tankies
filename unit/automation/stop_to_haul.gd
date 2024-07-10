extends ActionLeaf


func tick(actor, blackboard):
    if blackboard.get_value('haul_unit') == false:
        return FAILURE

    actor.state.force_end()
    actor.set_manual()
    return SUCCESS
