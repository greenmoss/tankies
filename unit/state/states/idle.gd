extends "../common/idle.gd"


func handle_input(event):
    if event.is_action_pressed("click"):
        owner.sounds.play_ready()

    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.look_direction = input_directions[direction]
            emit_signal("next_state", "scout")
            return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return

