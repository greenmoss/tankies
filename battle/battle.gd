extends Node
class_name Battle

var fighting: bool

func _ready():
    SignalBus.unit_attacked_unit.connect(_unit_attacked_unit)
    SignalBus.city_resisted_unit.connect(_city_resisted_unit)
    fighting = false

func _city_resisted_unit(attacker, defender):
    # TBD: pop up message
    if(attacker.my_team == defender.my_team):
        print(
            "Warning: refusing to attack city ",
            defender,
            " already owned by, ",
            attacker.my_team)
        return

    SignalBus.battle_started.emit(attacker, defender)
    fighting = true

    var winner = choose_winner(attacker, defender)

    attacker.start_fighting()
    $Target1.position = attacker.position
    $Target2.position = defender.position
    $FarOffBattle.play()

    if winner == attacker:
        $Target1.take_fire(false)
        $Target2.take_fire(false)
        await $Target2.damaged
        defender.surrender()
        attacker.request_move_into_city(defender)
        SignalBus.battle_finished.emit(attacker, defender)

    else:
        $Target1.take_fire(true)
        $Target2.take_fire(false)
        await $Target1.destroyed
        $Boom.play()
        fighting = false
        if is_instance_valid(attacker):
            await attacker.disband()
        SignalBus.battle_finished.emit(defender, attacker)

func _unit_attacked_unit(attacker, defender):
    if(attacker.my_team == defender.my_team):
        print(
            "Warning: refusing to attack unit ",
            defender,
            " already owned by, ",
            attacker.my_team)
        return

    SignalBus.battle_started.emit(attacker, defender)
    fighting = true

    var winner = attacker
    var loser = defender
    var win_target = $Target1
    var lose_target = $Target2
    if choose_winner(attacker, defender) == defender:
        win_target = $Target2
        lose_target = $Target1
        winner = defender
        loser = attacker

    winner.start_fighting()
    loser.start_fighting()
    win_target.position = winner.position
    lose_target.position = loser.position
    $Cacophony.play()
    win_target.take_fire(false)
    lose_target.take_fire(true)
    await lose_target.destroyed
    $Boom.play()
    fighting = false
    await winner.stop_fighting()
    # TBD: pop up message
    if is_instance_valid(loser):
        await loser.disband()
    SignalBus.battle_finished.emit(winner, loser)

func choose_winner(attacker, defender):
    var strength_total = attacker.attack_strength + defender.defense_strength
    var result = randi() % strength_total
    if result >= attacker.attack_strength:
        return defender
    return attacker
