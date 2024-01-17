extends Area2D

var selected = false
var mouse_is_over_me = false

var contains_units = []

var default_team = "NoTeam"
@export var my_team = default_team

## open cities do not resist capture
@export var open = false

func _ready():
    if my_team == null: my_team = "NoTeam"
    position = position.snapped(Vector2.ONE * Global.tile_size/2)
    assign()

func occupied():
    return not contains_units.is_empty()

func occupy(unit):

    #if(occupied()):
    #    print("Warning: refusing to add a unit to previously-occupied city")
    #    return

    if self.my_team != unit.my_team:
        capture(unit)
        # capturing uses up the unit, so don't append to units in city
        return

    contains_units.append(unit)

func resist(_unit):
    # TBD: play battle animation
    # TBD: roll dice
    # TBD: pop up message
    return

func capture(unit):
    if not open:
        resist(unit)

    remove_from_group(my_team)
    my_team = unit.my_team
    open = false # capturing a city removes its neutrality/openness
    assign()

    unit.disband()

func vacate(unit):
    if(not contains_units.has(unit)):
        print(
            "Warning: refusing to remove unit ",
            unit,
            " from city, ",
            self,
            ", which does not contain that unit")
        return
    var swap_contains = []
    for unit_to_check in contains_units:
        if unit_to_check == unit: continue
        swap_contains.append(unit_to_check)
    contains_units = swap_contains


func assign():
    modulate = Global.team_colors[my_team]
    add_to_group(my_team)
    add_to_group("Cities")
