extends "res://common/state_machine.gd"

@onready var attack = $attack
@onready var capture = $capture
@onready var crash = $crash
@onready var end = $end
# "ready" is reserved, using "idle" instead
@onready var idle = $idle
# "load" is reserved, using "haul" instead
@onready var haul = $haul
@onready var move = $move
@onready var scout = $scout
@onready var sleep = $sleep

var active_states = {}
var done_states = {}
var idle_states = {}

var unit:Unit

func _ready():

    active_states = {
        "attack": attack,
        "capture": capture,
        "crash": crash,
        "move": move,
        "scout": scout,
    }
    done_states = {
        "end": end,
        "haul": haul,
        "sleep": sleep,
    }
    idle_states = {
        "idle": idle,
    }
    states_map.merge(active_states)
    states_map.merge(done_states)
    states_map.merge(idle_states)

    if get_parent() is Unit:
        unit = get_parent()


func awaken():
    if is_asleep():
        current_state.awaken()


func force_end():
    # ignore any remaining moves
    current_state.next_state.emit('end')


func is_active() -> bool:
    return current_state.name in active_states.keys()


func is_asleep() -> bool:
    return current_state.name == 'sleep'


func is_idle() -> bool:
    return current_state.name in idle_states.keys()


func is_done() -> bool:
    return current_state.name in done_states.keys()


# typically used at the end of a turn
func rotate():
    if current_state.name == 'end':
        current_state.next_state.emit('idle')


func _change_state(state_name):
    if not _active:
        return
    super._change_state(state_name)


func handle_cursor_input(event):
    if not 'handle_cursor_input' in current_state: return
    current_state.handle_cursor_input(event)
