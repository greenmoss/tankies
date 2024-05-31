extends "../common/unit.gd"

var tracked:Unit


func update(_delta):
    if tracked == null:
        emit_signal("next_state", "find_unit")
        return
    if not is_instance_valid(tracked):
        tracked = null
        emit_signal("next_state", "find_unit")
        return
    if tracked.is_queued_for_deletion():
        tracked = null
        emit_signal("next_state", "find_unit")
        return

    # try again, until unit stops being active
    if tracked.state.is_active():
        return

    if not tracked.state.is_idle():
        emit_signal("next_state", "find_unit")
        return
    
    owner.state.mark_unit(tracked)
