extends Area2D

class_name City

var selected = false
var mouse_is_over_me = false

# if we are running this scene as an instantiated child, this is false
# set to true for debugging, e.g. to test cursor input
var standalone:bool

var default_team = "NoTeam"
@export var my_team = default_team

## open cities do not resist capture
@export var open = false

var build_duration = 4
var build_remaining:int = build_duration
var defense_strength = 1

@onready var icon = $icon
@onready var vision = $vision


func _on_mouse_entered():
    SignalBus.mouse_entered_city.emit(self)


func _on_mouse_exited():
    SignalBus.mouse_exited_city.emit(self)


# when we are debugging, e.g. in a standalone scene
# assume all input is for us, since there's no cursor
func _unhandled_input(event):
    if not standalone: return
    handle_cursor_input_event(event)


# the cursor chooses who gets the events
# thus, we do not use _unhandled_input() here
func handle_cursor_input_event(_event):
    pass
    #print("got event ",event)


func _ready():
    # when debugging, we are the root scene
    if get_parent() == get_tree().root:
        standalone = true
        position = Vector2(80,80)

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
    tween.tween_property(icon, "modulate",
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

