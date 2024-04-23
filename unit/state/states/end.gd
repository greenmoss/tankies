extends "../common/idle.gd"


func enter():
    SignalBus.unit_completed_moves.emit(owner.my_team)
    owner.sounds.stop_all()
    owner.inactive.done_moving()


func handle_input(event):
    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.sounds.play_denied()
            return

    if event.is_action_pressed('sleep'):
        emit_signal("next_state", "sleep")
        return


func exit():
    if owner.moves_remaining > 0:
        owner.inactive.awaken()
