class_name BTUnitIsAutomated extends ConditionLeaf

func tick(actor, _blackboard):
    if actor.automated:
        return SUCCESS
    return FAILURE
