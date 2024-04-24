extends "../common/move.gd"


var battle:Battle


func enter():
    battle = owner.get_node('..').battle
    if owner.target_unit == null:
        attack_city()
    else:
        attack_unit()


func attack_city():
    if(owner.target_city.my_team == owner.my_team):
        deny_invalid(owner.target_city)
        return

    if owner.target_city.open:
        emit_signal("next_state", "capture")
        return

    battle.attack_city(owner, owner.target_city)
    await SignalBus.battle_finished

    if battle.winner == owner:
        emit_signal("next_state", "capture")
        return

    lose()


func attack_unit():
    if(owner.target_unit.my_team == owner.my_team):
        deny_invalid(owner.target_unit)
        return

    battle.attack_unit(owner, owner.target_unit)
    await SignalBus.battle_finished

    if battle.winner == owner:
        owner.clear_targets()
        reduce_moves()
        return

    lose()


func deny_invalid(target):
    print(
        "Warning: refusing to attack target ",
        target,
        " already owned by, ",
        owner.my_team)
    owner.sounds.play_denied()
    owner.clear_targets()
    emit_signal("next_state", "idle")


func lose():
    # Normally we expect battle to disband this unit
    # but sometimes we get here, so handle this just in case
    reduce_moves()
