extends "res://common/state.gd"


# we select the first unit, then wait for all units to move
# human will do the magic of selecting, moving, waiting, go again
# this might change in the future once we have auto-units, go-to, etc
func enter():
    var next:Unit = owner.units.get_cardinal_closest_active(owner.cursor.get_position())
    if next != null:
        next.select_me()
        owner.cursor.state.mark_unit(next)


func update(_delta):
    if owner.units.are_done():
        emit_signal("next_state", "end")
