extends Area2D

class_name Unit

var facing = 0 # default/right
var in_city = null
var sleep_turns = 0

# if we are running this scene as an instantiated child, this is false
# set to true for debugging, e.g. to test cursor input
var standalone: bool

# path-finding
var _path = PackedVector2Array()

var moves_remaining: int
var attack_strength = 4
var defense_strength = 2
var look_direction = Vector2.RIGHT
var target_city:City = null
var target_unit:Unit = null

@export var moves_per_turn = 2
@export var my_team = "NoTeam"

@onready var inactive = $Inactive
@onready var ray = $RayCast2D
@onready var sounds = $Sounds
@onready var icon = $Icon
@onready var state = $state


func _on_mouse_entered():
    SignalBus.mouse_entered_unit.emit(self)


func _on_mouse_exited():
    SignalBus.mouse_exited_unit.emit(self)


# when we are debugging, e.g. in a standalone scene
# assume all input is for us, since there's no cursor
func _unhandled_input(event):
    if not standalone: return
    handle_cursor_input_event(event)


func clear_targets():
    target_city = null
    target_unit = null


# the cursor chooses who gets the events
# thus, we do not use _unhandled_input() here
func handle_cursor_input_event(event):
    state.handle_cursor_input(event)


func _ready():
    # when debugging, we are the root scene
    if get_parent() == get_tree().root:
        standalone = true
        position = Vector2(80,80)

    moves_per_turn = 2
    sleep_turns = 0
    position = position.snapped(Vector2.ONE * Global.tile_size / 2)
    await refill_moves()
    await assign_groups()
    _path.clear()


func move_toward(new_position):
    # NOTE: this makes no attempt at real path finding
    # consequently, this is best used to move to a neighboring coordinate/position
    var move_direction: Vector2 = (position - new_position).normalized()

    if(move_direction[0] > 0):
        look_direction = Vector2.LEFT
    elif(move_direction[1] > 0):
        look_direction = Vector2.UP
    elif(move_direction[0] < 0):
        look_direction = Vector2.RIGHT
    else:
        look_direction = Vector2.DOWN

    state.current_state.next_state.emit('scout')


func assign_groups():
    if my_team != null:
        modulate = Global.team_colors[my_team]
        add_to_group(my_team)
    add_to_group("Units")


func select_me():
    sounds.play_ready()


func set_in_city(city:City):
    in_city = city
    icon.set_from_city()


func refill_moves():
    moves_remaining = moves_per_turn
    state.rotate()


func disband():
    queue_free()
    # are we an invalid reference?
    # If not, perhaps a listener can benefit from knowing what we were
    SignalBus.unit_disbanded.emit(self)
