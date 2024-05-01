extends "res://common/state.gd"


func enter():
    owner.units.refill_moves()

    emit_signal("next_state", "wait")
