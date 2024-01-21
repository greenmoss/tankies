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
    SignalBus.unit_completed_moves.connect(_unit_completed_moves)
    SignalBus.want_next_unit.connect(_want_next_unit)
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

func _unit_completed_moves(unit):
    var team = unit.my_team
    $units.team_prior_unit[team] = unit
    $units.select_first(unit_queues[team])

func _want_next_unit(current_unit):
    var team = current_unit.my_team
    var unit_queue = unit_queues[team]
    var current_unit_index = -1
    var unit_count = unit_queue.size()
    for index in unit_count:
        if unit_queue[index] == current_unit:
            current_unit_index = index
            break
    if current_unit_index == -1:
        print("Could not find unit ", current_unit, " in the unit queue for team ", team, ". Giving up.")
        return

    var next_unit_index = current_unit_index + 1
    if next_unit_index >= unit_count: next_unit_index -= unit_count
    var next_unit = unit_queue[next_unit_index]

    if next_unit_index == current_unit_index: return
    # when unit captures a city, it is removed and we can no longer deselect it
    if is_instance_valid(current_unit):
      current_unit.deselect_me()
    next_unit.select_me()

func set_team_queues(team_name):
    city_queues[team_name] = $cities.make_team_queue(team_name)
    for city in city_queues[Global.human_team]:
        city.build_unit(turn_number)

    unit_queues[team_name] = $units.make_team_queue(team_name)
    $units.select_first(unit_queues[Global.human_team])

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
