extends "../common/idle.gd"


func enter():
    owner.unit.sounds.stop_all()
    owner.unit.display.set_hauled()
    owner.unit.display.set_inactive()


func exit():
    if owner.unit.moves_remaining > 0:
        owner.unit.display.set_active()
    owner.unit.display.remove_symbol()


func handle_cursor_input(event):
    if event.is_action_pressed("click") or event.is_action_pressed('haul'):
        if not owner.unit.is_hauled():
            unhaul()
            return

        owner.unit.sounds.play_ready()

    for direction in input_directions.keys():
        if event.is_action_pressed(direction):
            owner.unit.look_direction = input_directions[direction]
            emit_signal("next_state", "scout")
            return


func unhaul():
    owner.unit.display.remove_symbol()
    if owner.unit.moves_remaining > 0:
        emit_signal("next_state", "idle")
    else:
        emit_signal("next_state", "end")
