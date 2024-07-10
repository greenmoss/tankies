extends ActionLeaf


func tick(_actor, blackboard):

    blackboard.set_value("city_target", null)
    return SUCCESS
