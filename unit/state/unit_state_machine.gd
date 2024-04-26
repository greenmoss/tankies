extends "res://common/state_machine.gd"

@onready var attack = $attack
@onready var capture = $capture
@onready var end = $end
# "ready" would be nice, but it's reserved
@onready var idle = $idle
@onready var move = $move
@onready var scout = $scout
@onready var sleep = $sleep

var active_states = {}
var done_states = {}
var idle_states = {}

func _ready():

    active_states = {
        "attack": attack,
        "capture": capture,
        "move": move,
        "scout": scout,
    }
    done_states = {
        "end": end,
        "sleep": sleep,
    }
    idle_states = {
        "idle": idle,
    }
    states_map.merge(active_states)
    states_map.merge(done_states)
    states_map.merge(idle_states)


func force_end():
    # ignore any remaining moves
    current_state.next_state.emit('end')


func is_active() -> bool:
    return current_state.name in active_states.keys()


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
    current_state.handle_input(event)
