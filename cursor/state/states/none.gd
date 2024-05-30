extends "../common/unit.gd"


func handle_input(event):
    if event.is_action_pressed("click"):
        var clicked_unit:Unit = get_first_unit_under_mouse()
        if clicked_unit == null:
            return

        owner.state.mark_unit(clicked_unit)
        return

    if event.is_action_pressed('next'):
        emit_signal("next_state", "find_unit")
        return
