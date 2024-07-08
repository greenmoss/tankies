extends "../common/idle.gd"


func handle_cursor_input(event):
    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.unit.look_direction = input_directions[direction]
            emit_signal("next_state", "scout")
            return

    if event.is_action_pressed("click"):
        owner.unit.sounds.play_ready()
        return

    if event.is_action_pressed('haul'):
        emit_signal("next_state", "haul")
        return

    if event.is_action_pressed('skip'):
        emit_signal("next_state", "end")
        return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return
