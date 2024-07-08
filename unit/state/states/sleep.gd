extends "../common/idle.gd"


func awaken():
    owner.unit.display.remove_symbol()
    if owner.unit.moves_remaining > 0:
        emit_signal("next_state", "idle")
    else:
        emit_signal("next_state", "end")


func enter():
    owner.unit.display.set_asleep()


func exit():
    owner.unit.display.remove_symbol()


func handle_cursor_input(event):
    if event.is_action_pressed('sleep') or event.is_action_pressed('click'):
        awaken()
