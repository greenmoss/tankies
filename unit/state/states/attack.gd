extends "../common/move.gd"


var battle:Battle
var scout_vars:Dictionary


func enter():
    scout_vars = owner.state.states_vars['scout']
    battle = owner.get_node('..').battle
    if scout_vars['target_unit'] == null:
        attack_city()
    else:
        attack_unit()


func attack_city():
    if(scout_vars['target_city'].my_team == owner.my_team):
        deny_invalid(scout_vars['target_city'])
        return

    if scout_vars['target_city'].open:
        emit_signal("next_state", "capture")
        return

    battle.attack_city(owner, scout_vars['target_city'])
    await SignalBus.battle_finished

    if battle.winner == owner:
        emit_signal("next_state", "capture")
        return

    lose()


func attack_unit():
    if(scout_vars['target_unit'].my_team == owner.my_team):
        deny_invalid(scout_vars['target_unit'].my_team)
        return

    battle.attack_unit(owner, scout_vars['target_unit'])
    await SignalBus.battle_finished

    if battle.winner == owner:
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
    emit_signal("next_state", "idle")


func lose():
    # Normally we expect battle to disband this unit
    # but sometimes we get here, so handle this just in case
    reduce_moves()
