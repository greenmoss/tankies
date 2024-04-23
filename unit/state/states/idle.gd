extends "../common/idle.gd"


func enter():
    if owner.sounds != null:
        owner.sounds.play_ready()


func handle_input(event):
    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.look_direction = input_directions[direction]
            emit_signal("next_state", "pre_move")
            return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return

