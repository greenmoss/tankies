extends Node

var fighting: bool

func _ready():
    SignalBus.unit_attacked_unit.connect(_unit_attacked_unit)
    SignalBus.city_resisted_unit.connect(_city_resisted_unit)
    fighting = false

func _city_resisted_unit(attacker, defender):
    # TBD: roll dice
    # TBD: pop up message
    if(attacker.my_team == defender.my_team):
        print(
            "Warning: refusing to attack city ",
            defender,
            " already owned by, ",
            attacker.my_team)
        return

    fighting = true
    attacker.start_fighting()
    $Target1.position = attacker.position
    $Target2.position = defender.position
    $FarOffBattle.play()
    $Target1.take_fire(false)
    $Target2.take_fire(false)
    await $Target2.damaged
    defender.surrender()
    attacker.request_move_into_city(defender)

func _unit_attacked_unit(attacker, defender):
    if(attacker.my_team == defender.my_team):
        print(
            "Warning: refusing to attack unit ",
            defender,
            " already owned by, ",
            attacker.my_team)
        return

    fighting = true
    attacker.start_fighting()
    defender.start_fighting()
    $Target1.position = attacker.position
    $Target2.position = defender.position
    $Cacophony.play()
    $Target1.take_fire(false)
    $Target2.take_fire(true)
    # TBD: roll dice
    await $Target2.destroyed
    $Boom.play()
    fighting = false
    attacker.stop_fighting()
    # TBD: pop up message
    defender.disband()
