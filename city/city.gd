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

func attacked_by(unit):
    if(unit.my_team == my_team):
        print(
            "Warning: refusing to attack city ",
            self,
            " already owned by, ",
            unit.my_team)
        return

    if not occupied():
        capture_by(unit)
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

func occupy_by(unit):
    if self.my_team != unit.my_team:
        capture_by(unit)
        # capturing uses up the unit, so don't append to units in city
        return

    contains_units.append(unit)

func resist(attacker):
    if(attacker.my_team == my_team):
        print(
            "Warning: refusing to resist unit ",
            attacker,
            " already owned by, ",
            my_team)
        return
    SignalBus.city_resisted_unit.emit(attacker, self)

func capture_by(unit):
    if not open:
        resist(unit)
        return

    $Marching.play()
    remove_from_group(my_team)
    my_team = unit.my_team
    fortify()
    assign()
    SignalBus.city_captured.emit(self)

    unit.disband()

func fortify():
    open = false

func surrender():
    open = true

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
    var tween = create_tween()
    tween.tween_property(self, "modulate",
        Global.team_colors[my_team],
        1.0
        ).set_trans(Tween.TRANS_SINE)
    #modulate = Global.team_colors[my_team]
    add_to_group(my_team)
    add_to_group("Cities")

func build_unit():
    if my_team == default_team: return
    build_remaining -= 1
    if build_remaining == 0:
        SignalBus.city_requested_unit.emit(self)
        build_remaining = build_duration

