extends "../common/move.gd"


func enter():
    if not owner.unit.can_attack():
        emit_signal("next_state", "block")
        return

    battle = owner.unit.get_node('..').battle

    if owner.unit.state.scout.target_units.is_empty():
        attack_city()
    else:
        attack_unit()


func attack_city():
    if(owner.unit.state.scout.target_city.my_team == owner.unit.my_team):
        deny_invalid(owner.unit.state.scout.target_city)
        return

    if owner.unit.state.scout.target_city.open:
        emit_signal("next_state", "capture")
        return

    battle.attack_city(owner.unit, owner.unit.state.scout.target_city)
    await SignalBus.battle_finished

    if battle.winner == owner.unit:
        emit_signal("next_state", "capture")
        return

    lose()


func attack_unit():
    if(owner.unit.state.scout.target_units[0].my_team == owner.unit.my_team):
        deny_invalid(owner.unit.state.scout.target_units[0].my_team)
        return

    var targeted_unit:Unit = null
    for unit in owner.unit.state.scout.target_units:
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        if unit.is_hauled(): continue
        targeted_unit = unit
        break

    battle.attack_unit(owner.unit, targeted_unit)
    await SignalBus.battle_finished

    if battle.winner == owner.unit:
        reduce_moves()
        return

    lose()


func deny_invalid(target):
    push_warning(
        "refusing to attack target ",
        target,
        " already owned by, ",
        owner.unit.my_team)
    owner.unit.sounds.play_denied()
    emit_signal("next_state", "idle")


func lose():
    # Normally we expect battle to disband this unit
    # but sometimes we get here, so handle this just in case
    reduce_moves()
