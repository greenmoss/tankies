extends "../common/move.gd"


func enter():
    if not owner.unit.has_fuel():
        push_warning("unit ",owner.unit," entered state crash, but has 0 fuel capacity; ignoring")
        emit_signal("next_state", "idle")
        return

    await owner.unit.sounds.play_descend()

    # if we are standalone/debugging, there is no battle node
    if owner.unit.standalone:
        owner.unit.disband()

    else:
        battle = owner.unit.get_node('..').battle
        battle.crash(owner.unit)

