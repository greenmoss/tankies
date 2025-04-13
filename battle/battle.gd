extends Node2D
class_name Battle

var fighting:bool
var winner
enum Sides {Attacker, Defender}

# for testing, this doesn't work
#  var original_choose_winner = Battle.choose_winner
# so instead we use these two class variables
var fake_winner:Sides = Sides.Attacker
var really_choose = true

func _ready():
    Global.set_z(self, 'battle')
    fighting = false

func attack_city(unit:Unit, city:City):
    # TBD: pop up message
    SignalBus.battle_started.emit(unit, city)
    fighting = true

    winner = choose_winner(unit, city)

    $Target1.position = unit.position
    $Target2.position = city.position
    $FarOffBattle.play()

    if winner == unit:
        $Target1.take_fire(false)
        $Target2.take_fire(false)
        await $Target2.damaged

    else:
        $Target1.take_fire(true)
        $Target2.take_fire(false)
        await $Target1.destroyed
        $Boom.play()

        if is_instance_valid(unit):
            await unit.disband()

    fighting = false
    SignalBus.battle_finished.emit(city, unit)


func attack_unit(attacker:Unit, defender:Unit):
    SignalBus.battle_started.emit(attacker, defender)
    fighting = true

    winner = attacker
    var loser = defender
    var win_target = $Target1
    var lose_target = $Target2
    if choose_winner(attacker, defender) == defender:
        win_target = $Target2
        lose_target = $Target1
        winner = defender
        loser = attacker

    win_target.position = winner.position
    lose_target.position = loser.position
    $Cacophony.play()
    win_target.take_fire(false)
    lose_target.take_fire(true)
    await lose_target.destroyed
    $Boom.play()

    if is_instance_valid(loser):
        await loser.disband()

    fighting = false
    # TBD: pop up message
    SignalBus.battle_finished.emit(winner, loser)


func choose_winner(attacker:Unit, defender):
    var strength_total = attacker.attack_strength + defender.defense_strength
    var result = randi() % strength_total

    if really_choose:
        #print("choosing a random winner")
        if result >= attacker.attack_strength:
            return defender
        return attacker

    if fake_winner == Sides.Attacker:
        #print("winner is always attacker")
        return attacker

    #print("winner is always defender")
    return defender


func crash(lost:Unit):
    $Target1.position = lost.position
    $Boom.play()
    $Target1.destroy()

    if is_instance_valid(lost):
        await lost.disband()


func override_winner(side:Sides):
    really_choose = false
    fake_winner = side


func restore_winner():
    really_choose = true
    fake_winner = Sides.Attacker
