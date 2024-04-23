extends "../common/move.gd"


func enter():
    await animate()
    reduce_moves()


func handle_input(event):
    return super.handle_input(event)


func reduce_moves():
    owner.moves_remaining -= 1
    if owner.moves_remaining <= 0:
        emit_signal("next_state", "end")
        return

    emit_signal("next_state", "idle")
