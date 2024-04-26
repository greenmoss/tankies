extends "res://common/state.gd"


func update(_delta):
    if owner.units.are_active():
        return

    if owner.units.are_done:
        emit_signal("next_state", "end")

    emit_signal("next_state", "plan")
