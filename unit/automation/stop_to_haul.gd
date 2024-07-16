extends ActionLeaf


func tick(actor, blackboard):
    var haul_unit = blackboard.get_value('haul_unit')
    #print("in stop to haul, haul unit is ",haul_unit)
    match haul_unit:
        false, null:
            return FAILURE

    actor.state.force_end()
    actor.set_manual()
    return SUCCESS
