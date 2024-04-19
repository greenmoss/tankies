extends "res://common/state_machine.gd"

@onready var attack = $attack
#REF
#@onready var collide = $collide
@onready var end = $end
# "ready" would be nice, but it's reserved
@onready var idle = $idle
@onready var look = $look
@onready var move = $move
@onready var sleep = $sleep

func _ready():
    states_map = {
        # active
        "attack": attack,
        "look": look,
        "move": move,

        # done
        "end": end,
        "sleep": sleep,

        # idle
        "idle": idle,
    }


func is_active() -> bool:
    #print("checking if active, state is ",state.current_state.name)
    return current_state.name in ['attack', 'move', 'look']


func is_idle() -> bool:
    return current_state.name == 'idle'


func is_done() -> bool:
    return current_state.name in ['end', 'sleep']


# typically used at the end of a turn
func rotate():
    if current_state.name == 'end':
        current_state.next_state.emit('idle')
    #pass


func _change_state(state_name):
    # The base state_machine interface this node extends does most of the work.
    if not _active:
        return
    if state_name in ["attack", "collide"]:
        states_stack.push_front(states_map[state_name])
    super._change_state(state_name)

#func _unhandled_input(_event):
#    pass
#    # Here we only handle input that can interrupt states, attacking in this case,
#    # otherwise we let the state node handle it.
#    #if event.is_action_pressed("attack"):
#    #    if current_state in [attack]:
#    #        return
#    #    _change_state("attack")
#    #    return
#    current_state.handle_input(event)

func handle_cursor_input(event):
    current_state.handle_input(event)
