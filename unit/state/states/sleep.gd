extends "../common/idle.gd"


func enter():
    owner.inactive.sleep_infinity()


func handle_input(event):
    if event.is_action_pressed('sleep') or event.is_action_pressed('click'):
        owner.inactive.awaken()
        if owner.moves_remaining > 0:
            emit_signal("next_state", "idle")
        else:
            emit_signal("next_state", "end")


func update(_delta):
    pass
