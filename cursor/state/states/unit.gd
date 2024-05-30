extends "../common/unit.gd"

var marked:Unit

var square_throb_time = 0
var square_throb_duration = 1.5  # duration of the cursor square throb animation

var big_circle_time = 0
var big_circle_duration = 0.75  # duration of the cursor big circle fade

@onready var big_circle = $big_circle
@onready var cool_down = $cool_down
@onready var square_marker = $square_marker


func enter():
    if marked == null:
        emit_signal("next_state", "find_unit")
        return
    if not is_instance_valid(marked):
        emit_signal("next_state", "find_unit")
        return
    if marked.is_queued_for_deletion():
        emit_signal("next_state", "find_unit")
        return

    owner.position = marked.position

    square_throb_time = 0
    big_circle_time = 0

    square_marker.visible = true
    big_circle.visible = true


func exit():
    square_marker.visible = false
    big_circle.visible = false


func handle_input(event):
    if event.is_action_pressed("click"):
        var clicked_unit:Unit = get_first_unit_under_mouse()
        if clicked_unit == null:
            marked = null
            emit_signal("next_state", "none")
            return
        # already selected, so deselect
        if clicked_unit == marked:
            marked = null
            emit_signal("next_state", "none")
            return

        marked = clicked_unit
        emit_signal("next_state", "unit")
        return

    if event.is_action_pressed('next'):
        emit_signal("next_state", "find_unit")
        return

    marked.handle_cursor_input_event(event)


func update(delta):
    if marked == null:
        emit_signal("next_state", "find_unit")
        return
    if not is_instance_valid(marked):
        marked = null
        emit_signal("next_state", "find_unit")
        return
    if marked.is_queued_for_deletion():
        marked = null
        emit_signal("next_state", "find_unit")
        return
    if marked.state.is_active():
        owner.state.track_unit.tracked = marked
        emit_signal("next_state", "track_unit")
        return

    if square_marker.visible:
        if square_throb_time < square_throb_duration:
            square_throb_time += delta
            square_marker.modulate.a = lerp(1.0, 0.25, square_throb_time / square_throb_duration)
        else:
            square_throb_time = 0

    if big_circle.visible:
        big_circle_time += delta
        big_circle.modulate.a = lerp(1.0, 0.25, big_circle_time / big_circle_duration)
        if big_circle_time > big_circle_duration:
            big_circle_time = 0
            big_circle.visible = false
