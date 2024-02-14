extends Area2D

class_name City

var selected = false
var mouse_is_over_me = false

var contains_units = []

var default_team = "NoTeam"
@export var my_team = default_team

## open cities do not resist capture
@export var open = false

var build_duration :int = 4
var build_remaining :int = build_duration

func _ready():
    SignalBus.city_captured.connect(_city_captured)
    if my_team == null: my_team = "NoTeam"
    build_remaining = build_duration + 1 # at start we will subtract a turn, so add it back in here
    position = position.snapped(Vector2.ONE * Global.tile_size/2)
    assign()

func _city_captured(captured_city):
    if captured_city != self: return
    build_unit()

func attack_with(unit):
    if(unit.my_team == my_team):
        print(
            "Warning: refusing to attack city ",
            self,
            " already owned by, ",
            unit.my_team)
        return

    if not occupied():
        capture_with(unit)
        return

    var defender : Area2D = contains_units[0]
    unit.attack(defender)

func is_open_to_team(team) -> bool:
    if open:
        return true
    if team == my_team:
        return true
    return false

func occupied() -> bool:
    return not contains_units.is_empty()

func occupy_with(unit):
    if self.my_team != unit.my_team:
        capture_with(unit)
        # capturing uses up the unit, so don't append to units in city
        return

    contains_units.append(unit)

func resist(_unit):
    # TBD: play battle animation
    # TBD: roll dice
    # TBD: pop up message
    return

func capture_with(unit):
    if not open:
        resist(unit)

    remove_from_group(my_team)
    my_team = unit.my_team
    open = false # capturing a city removes its neutrality/openness
    assign()
    SignalBus.city_captured.emit(self)

    unit.disband()

func vacated_by(unit):
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

func build_unit():
    if my_team == default_team: return
    build_remaining -= 1
    if build_remaining == 0:
        SignalBus.city_requested_unit.emit(self)
        build_remaining = build_duration

