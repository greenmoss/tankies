extends ActionLeaf


func tick(actor, blackboard):
    var unit_candidates = blackboard.get_value("unit_candidates")
    var terrain = blackboard.get_value("terrain")

    #print("unit ",actor," setting closest candidate from ",unit_candidates," with moves remaining ",actor.moves_remaining)

    if (unit_candidates == null) or (terrain == null):
        blackboard.set_value("unit_target", null)
        return FAILURE

    #print("here1")
    var distances = unit_candidates.keys()
    distances.sort()
    for distance in distances:
        for nearby_enemy in unit_candidates[distance]:
            #print("here2")

            # these two can happen after a battle where the target was destroyed
            # consider the move invalid and try again
            if not is_instance_valid(nearby_enemy):
                continue
            if nearby_enemy.is_queued_for_deletion():
                continue
            #print("here3")

            # we should never see this, because we should only be moving on our turn
            if nearby_enemy.state.is_active():
                push_warning("nearby enemy unit ",nearby_enemy," is active, even though it is our turn")
                continue
            #print("here4")

            # ensure we are able to get to the unit
            var navigation = actor.navigation
            #if actor.is_hauled(): navigation = 'air'
            #print("here4a, navigation is ", navigation)
            var found_path = actor.plan.set_path_to_unit(nearby_enemy, terrain, navigation)
            #print("path is ",found_path)
            if not found_path:
                continue

            blackboard.set_value("unit_target", nearby_enemy)
            return SUCCESS

    #print("here5")
    blackboard.set_value("unit_target", null)
    return FAILURE
