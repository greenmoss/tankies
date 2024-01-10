extends Node2D

func _ready() -> void:
    # source: https://stackoverflow.com/a/68675270/1090611
    SignalBus.unit_collided.connect(_unit_collided)

func _unit_collided(unit, target):
    '''
    What does the unit do when it hits something?

    For a friendly city: move inside
    For a neutral or hostile city: attack
    For a friendly unit: deny the move
    For a hostile unit: attack
    '''
    if target.is_in_group("Cities"):
        print("target city")
        unit.move_to_requested()
        return

    unit.deny_move()
