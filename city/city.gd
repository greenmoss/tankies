extends Area2D

var selected = false
var mouse_is_over_me = false

var contains_unit = null

@export var my_team = "NoTeam"

## open cities do not resist capture
@export var open = false

func _ready():
    position = position.snapped(Vector2.ONE * Global.tile_size/2)
    assign_groups()

func occupied():
    if(contains_unit == null):
        return(false)
    return(true)

func occupy(unit):

    if(occupied()):
        print("Warning: refusing to add a unit to previously-occupied city")
        return

    if my_team != unit.my_team:
        capture(unit)
    contains_unit = unit

func resist(unit):
    # TBD: play battle animation
    # TBD: roll dice
    # TBD: pop up message
    return

func capture(unit):
    if not open:
        resist(unit)

    remove_from_group(my_team)
    my_team = unit.my_team
    assign_groups()

    unit.disband()

func vacate(unit):
    if(! occupied()):
        print(
            "Warning: refusing to remove unit ",
            unit,
            " from city, which is unoccupied ")
        return
    if(contains_unit != unit):
        print(
            "Warning: refusing to remove unit ",
            unit,
            " from city, which is already occupied by unit ",
            contains_unit)
        return
    contains_unit = null


func assign_groups():
    modulate = Global.team_colors[my_team]
    add_to_group(my_team)
    add_to_group("Cities")
