extends Area2D

class_name City

var selected = false
var mouse_is_over_me = false

var default_team = "NoTeam"
@export var my_team = default_team

## open cities do not resist capture
@export var open = false

var build_duration = 4
var build_remaining: int = build_duration
var defense_strength = 1

func _ready():
    SignalBus.city_captured.connect(_city_captured)
    if my_team == null: my_team = "NoTeam"
    clear_build()
    build_remaining += 1 # at start we will subtract a turn, so add it back in here
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

    capture_by(unit)

func is_open_to_team(team) -> bool:
    if open:
        return true
    if team == my_team:
        return true
    return false

func occupy_by(unit):
    if self.my_team != unit.my_team:
        capture_by(unit)
        # capturing uses up the unit, so don't append to units in city
        return

func resist(attacker):
    if(attacker.my_team == my_team):
        print(
            "Warning: refusing to resist unit ",
            attacker,
            " already owned by, ",
            my_team)
        return
    SignalBus.city_resisted_unit.emit(attacker, self)

func clear_build():
    build_remaining = build_duration

func capture_by(unit):
    if not open:
        resist(unit)
        return

    $Marching.play()
    remove_from_group(my_team)
    my_team = unit.my_team
    fortify()
    assign()
    clear_build()
    SignalBus.city_captured.emit(self)

    unit.disband()

func fortify():
    open = false

func surrender():
    open = true

func assign():
    var tween = create_tween()
    tween.tween_property(self, "modulate",
        Global.team_colors[my_team],
        1.0
        ).set_trans(Tween.TRANS_SINE)
    add_to_group(my_team)
    add_to_group("Cities")

func build_unit():
    if my_team == default_team: return
    build_remaining -= 1
    if build_remaining == 0:
        SignalBus.city_requested_unit.emit(self)
        build_remaining = build_duration

