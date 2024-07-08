extends "../common/idle.gd"


func enter():
    owner.unit.sounds.stop_all()
    owner.unit.display.set_inactive()


func handle_cursor_input(event):
    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.unit.sounds.play_denied()
            return

    if event.is_action_pressed('haul'):
        emit_signal("next_state", "haul")
        return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return


func exit():
    if owner.unit.moves_remaining > 0:
        owner.unit.display.set_active()
