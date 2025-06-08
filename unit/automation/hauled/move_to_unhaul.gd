@tool
extends ActionLeaf


func tick(actor, blackboard):
    if not actor.is_hauled(): return FAILURE

    var move_position = blackboard.get_value("move_position")
    if move_position == null:
        return FAILURE

    if move_position == actor.position:
        return FAILURE

    if move_position in actor.state.block.get_positions():
        return FAILURE
    #print("moving to position ",move_position," with blocked looks ",actor.state.block.get_positions())

    var obstacles = blackboard.get_value("obstacles")
    var terrain = blackboard.get_value("terrain")
    var path = actor.find_path_to(move_position, terrain, obstacles)
    print("unit ",actor," at point ",Global.as_grid(actor.position)," move to unhaul path is ",Global.array_as_grid(path))

    actor.set_manual()
    actor.move_toward(move_position)
    return SUCCESS

