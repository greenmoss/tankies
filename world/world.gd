extends Node2D

@export var turn_number = 0

var city_queues = {}
var unit_queues = {}

var start_next_turn
## Example use case: reactivate unit at beginning of turn
#var team_current = {}

func _ready():
    SignalBus.city_captured.connect(_city_captured)
    SignalBus.unit_collided.connect(_unit_collided)
    turn_number = 0
    start_next_turn = true

func _physics_process(_delta):
    var winner = check_winner()
    if(winner != null):
        SignalBus.team_won.emit(winner)
        return

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

## turns code
func start_turn():
    var previous_turn = turn_number
    turn_number += 1
    $TurnOverlay.display(previous_turn, turn_number)
    start_next_turn = false

    # only human cities build units for now
    for city in $cities.make_team_queue(Global.human_team):
        city.build_unit(turn_number)

    $teams.start_turn()

func check_turn_done():
    if $teams.are_done():
        end_turn()

func end_turn():
    start_next_turn = true

func check_winner():
    var teams_with_cities = []
    var city_owners = $cities.tally_owners()
    for team in city_owners.keys():
        if city_owners[team] == 0: continue
        teams_with_cities.append(team)
    if(teams_with_cities.size() != 1):
        return null
    return(teams_with_cities[0])
