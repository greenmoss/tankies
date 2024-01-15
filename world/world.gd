extends Node2D

@export var turn_number = 0

func _ready() -> void:
    # source: https://stackoverflow.com/a/68675270/1090611
    SignalBus.unit_collided.connect(_unit_collided)

func _physics_process(_delta):
    if($units.taking_turn):
        $units.run_turn_loop()
    else:
        start_next_turn()

func start_next_turn():
    var previous_turn = turn_number
    turn_number += 1
    $TurnOverlay.display(previous_turn, turn_number)
    $units.start_turn()

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
