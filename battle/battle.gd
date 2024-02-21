extends Node

var fighting: bool
var attacker: Area2D
var defender: Area2D

func _ready():
    SignalBus.unit_attacking_unit.connect(_unit_attacking_unit)
    fighting = false
    $Target1.destroyed.connect(_handle_target1_destroyed)
    $Target2.destroyed.connect(_handle_target2_destroyed)

func _unit_attacking_unit(attacking_unit, defending_unit):
    attacker = attacking_unit
    defender = defending_unit
    # TBD: roll dice
    # TBD: pop up message
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

func _handle_target1_destroyed():
    end_unit_winner_loser(defender, attacker)

func _handle_target2_destroyed():
    end_unit_winner_loser(attacker, defender)

func end_unit_winner_loser(winner, loser):
    $Boom.play()
    fighting = false
    winner.stop_fighting()
    loser.disband()
