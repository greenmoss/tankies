class_name BTUnitIsIdle extends ConditionLeaf

func tick(actor, _blackboard):
    if actor.state.is_idle():
        return SUCCESS
    return FAILURE
