extends ActionLeaf

func tick(actor, _blackboard):
    #if actor.completed_your_action:
    #     return SUCCESS
    #if actor.cant_do_your_action:
    #    return FAILURE
    #actor.do_your_action()
    if actor.state.is_idle():
        #print("action1 returns running")
        return RUNNING
    #print("action1 returns failure")
    return FAILURE

