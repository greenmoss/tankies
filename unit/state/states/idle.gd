extends "res://common/state.gd"

var inputs = {
    "right": Vector2.RIGHT,
    "left": Vector2.LEFT,
    "up": Vector2.UP,
    "down": Vector2.DOWN,
    }

func enter():
    print("in state:idle enter")
    #REF new intermediate state for "clicked on"?
    #owner.sounds.play_ready()
    #owner.get_node(^"AnimationPlayer").play("idle")


func handle_input(event):
    print("in state:idle handle input: ",event)
    for direction in inputs.keys():
        if event.is_action_pressed(direction):
            print("requested direction ",direction)
            owner.look_direction = inputs[direction]
            emit_signal("next_state", "move")
            return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return
    #return super.handle_input(event)

func update(_delta):
    pass
    #print("in state:idle for unit ",self,", update")
    #var input_direction = get_input_direction()
    #if input_direction:
    #    emit_signal("next_state", "move")
