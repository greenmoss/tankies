extends "../common/unit.gd"

var marked:Unit
var previous_marked:Unit

var square_throb_time = 0
var square_throb_duration = 1.5  # duration of the cursor square throb animation

var big_circle_time = 0
var big_circle_duration = 0.75  # duration of the cursor big circle fade

@onready var big_circle = $big_circle
@onready var cool_down = $cool_down
@onready var half_range_marker = $half_range_marker
@onready var range_marker = $range_marker
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

    if marked.state.is_asleep():
        marked.state.awaken()

    if marked.state.is_hauled():
        marked.state.unhaul()

    owner.position = marked.position

    SignalBus.cursor_marked_unit.emit(marked)

    square_throb_time = 0
    big_circle_time = 0

    square_marker.visible = true

    if marked.has_fuel():
        show_fuel_markers()

    if marked != previous_marked:
        marked.select_me()
        big_circle.visible = true
        previous_marked = marked


func exit():
    square_marker.visible = false
    big_circle.visible = false
    half_range_marker.visible = false
    range_marker.visible = false


func handle_input(event):
    if event.is_action_pressed("click"):
        var clicked_city:City = get_city_under_mouse()
        if clicked_city != null:
            previous_marked = null
            marked = null
            owner.state.mark_city(clicked_city)
            return

        var clicked_units:Array[Unit] = get_all_units_under_mouse()
        if clicked_units.size() == 0:
            previous_marked = null
            marked = null
            emit_signal("next_state", "none")
            return

        var ordered_units:Array[Unit] = owner.get_team().units.get_at_position(clicked_units[0].position)

        # last node is on top, so that becomes the top unit in the stack
        ordered_units.reverse()

        for clicked_unit in ordered_units:
            if clicked_unit != marked: continue

            # one unit in stack, already selected
            if ordered_units.size() == 1:
                previous_marked = null
                marked = null
                emit_signal("next_state", "none")
                return

            # multiple units in stack, one is already selected
            owner.state.units.units = ordered_units
            owner.state.units.marked = marked
            previous_marked = null
            marked = null
            emit_signal("next_state", "units")
            return

        # non-selected/new unit
        marked = ordered_units[0]
        emit_signal("next_state", "unit")
        return

    if event.is_action_pressed('next'):
        owner.state.find_unit.nearby = marked
        emit_signal("next_state", "find_unit")
        return

    if event.is_action_pressed("escape"):
        previous_marked = null
        marked = null
        emit_signal("next_state", "none")
        return

    if event.is_action_pressed("skip"):
        marked.handle_cursor_input_event(event)
        previous_marked = null
        marked = null
        emit_signal("next_state", "find_unit")
        return

    marked.handle_cursor_input_event(event)


func show_fuel_markers():
    var limit = (marked.fuel_remaining * Global.tile_size) + (range_marker.width / 2) - Global.half_tile_size
    var half = (int(float(marked.fuel_remaining) / 2.0) * Global.tile_size) + (half_range_marker.width / 2) - Global.half_tile_size
    range_marker.points[0] = Vector2(-limit, -limit)
    range_marker.points[1] = Vector2( limit, -limit)
    range_marker.points[2] = Vector2( limit,  limit)
    range_marker.points[3] = Vector2(-limit,  limit)

    # only show the half-marker if it's at least a tile away
    if half > Global.tile_size:
        half_range_marker.points[0] = Vector2(-half, -half)
        half_range_marker.points[1] = Vector2( half, -half)
        half_range_marker.points[2] = Vector2( half,  half)
        half_range_marker.points[3] = Vector2(-half,  half)
        half_range_marker.visible = true

    range_marker.visible = true


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

    if marked.state.is_asleep():
        owner.state.find_unit.nearby = marked
        emit_signal("next_state", "find_unit")

    if marked.state.is_hauled():
        owner.state.find_unit.nearby = marked
        emit_signal("next_state", "find_unit")

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
