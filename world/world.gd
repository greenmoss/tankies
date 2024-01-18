extends Node2D

@export var turn_number = 0

var city_queues = {}
var unit_queues = {}

var start_next_turn

func _ready():
    SignalBus.unit_collided.connect(_unit_collided)
    SignalBus.city_captured.connect(_city_captured)
    start_next_turn = true

func _physics_process(_delta):
    if(start_next_turn):
        start_turn()
    else:
        check_turn_done()

func _city_captured(city):
    city.reset_build(turn_number)

func _unit_collided(unit, target):
    '''
    What does the unit do when it hits something?

    For a friendly city: move inside
    For a neutral or hostile city: attack
    For a friendly unit: deny the move
    For a hostile unit: attack
    '''
    if target.is_in_group("Cities"):
        if target.occupied():
            unit.deny_move()
            return

        unit.move_to_requested()
        unit.enter_city(target)
        return

    unit.deny_move()

func set_team_queues(team_name):
    city_queues[team_name] = $cities.make_team_queue(team_name)
    for city in city_queues[Global.human_team]:
        city.build_unit(turn_number)

    unit_queues[team_name] = $units.make_team_queue(team_name)

## turns code
func start_turn():
    var previous_turn = turn_number
    turn_number += 1
    $TurnOverlay.display(previous_turn, turn_number)
    start_next_turn = false

    set_team_queues(Global.human_team)
    set_team_queues(Global.ai_team)

func check_turn_done():
    # TODO: switch to team "phases"
    # so we are only checking one team within this loop
    # this is probably faster than re-checking every unit every time
    var humans_done = true
    for unit in unit_queues[Global.human_team]:
        # this happens when we remove a unit
        if not is_instance_valid(unit): continue

        if unit.has_more_moves():
            humans_done = false
            break

    var ai_done = true
    if(humans_done and ai_done):
        end_turn()

func end_turn():
    start_next_turn = true
