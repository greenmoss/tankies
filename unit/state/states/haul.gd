extends "../common/idle.gd"


func enter():
    owner.unit.sounds.stop_all()
    owner.unit.display.set_inactive()


func handle_cursor_input(event):
    if event.is_action_pressed("click"):
        owner.unit.sounds.play_ready()

    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.unit.look_direction = input_directions[direction]
            emit_signal("next_state", "scout")
            return


func exit():
    if owner.unit.moves_remaining > 0:
        owner.unit.display.set_active()
