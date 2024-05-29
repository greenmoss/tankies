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

@onready var vision = $vision


func _ready():
    if my_team == null: my_team = "NoTeam"
    clear_build()
    position = position.snapped(Vector2.ONE * Global.tile_size/2)
    assign()


func is_open_to_team(team) -> bool:
    if open:
        return true
    if team == my_team:
        return true
    return false


func clear_build():
    # add one more, to account for current turn
    build_remaining = build_duration + 1


func capture_by(unit):
    SoundManager.interrupt_channel("capture_city", "res://unit/sounds/marching.wav")
    remove_from_group(my_team)
    my_team = unit.my_team
    fortify()
    assign()
    clear_build()


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
    SignalBus.city_updated_vision.emit(self)


func build_unit():
    if my_team == default_team: return
    build_remaining -= 1
    if build_remaining == 0:
        SignalBus.city_requested_unit.emit(self)
        build_remaining = build_duration

