extends ConditionLeaf

func tick(actor, _blackboard):
    #if true:
    #    return SUCCESS
    if actor.state.is_idle():
        #print("condition1 returns success")
        return SUCCESS
    #print("condition1 returns failure")
    return FAILURE
