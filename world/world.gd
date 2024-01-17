extends Node2D

@export var turn_number = 0

var turn_queues = {}

var taking_turn = false

func _ready():
    # source: https://stackoverflow.com/a/68675270/1090611
    SignalBus.unit_collided.connect(_unit_collided)

func _physics_process(_delta):
    if(taking_turn):
        run_turn_loop()
    else:
        start_turn()

func reset_group(group_name):
    for nodes in get_tree().get_nodes_in_group(group_name):
        nodes.remove_from_group(group_name)

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

func set_team_turn_queue(team_name):
    turn_queues[team_name] = $units.make_team_queue(team_name)

## turns code
func start_turn():
    var previous_turn = turn_number
    turn_number += 1
    $TurnOverlay.display(previous_turn, turn_number)
    taking_turn = true

    set_team_turn_queue(Global.human_team)
    if turn_queues[Global.human_team] == []:
        $units.create(Global.human_team, Vector2(200, 200))
        set_team_turn_queue(Global.human_team)
    set_team_turn_queue(Global.ai_team)

func run_turn_loop():
    var humans_done = true
    for unit in turn_queues[Global.human_team]:
        # this happens when we remove a unit
        if not is_instance_valid(unit): continue

        if unit.has_more_moves():
            humans_done = false
            break

    var ai_done = true
    if(humans_done and ai_done):
        end_turn()

func end_turn():
    taking_turn = false
