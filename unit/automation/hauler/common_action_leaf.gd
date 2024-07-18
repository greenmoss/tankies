extends '../common_action_leaf.gd'


func get_idle_hauled(actor:Unit) -> Unit:
    var unit:Unit = null
    for hauled_unit in actor.hauled_units:
        if hauled_unit.moves_remaining <= 0: continue
        unit = hauled_unit
        break
    return unit
