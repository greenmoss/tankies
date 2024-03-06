extends Sprite2D

var throbber_time = 0
var throbber_duration = 1.5  # duration of the cursor throbber animation
var target_time = 0
var target_duration = 0.75  # duration of the cursor target animation
var units_under_mouse = {}
var selected_unit : Area2D
var controller_team = Global.human_team

func _ready():
    units_under_mouse = {}
    selected_unit = null
    SignalBus.unit_disbanded.connect(_unit_disbanded)
    SignalBus.units_selected_next.connect(_units_selected_next)
    SignalBus.mouse_entered_unit.connect(_mouse_entered_unit)
    SignalBus.mouse_exited_unit.connect(_mouse_exited_unit)

func _physics_process(delta):
    if not visible: return
    throb(delta)
    target(delta)

func _mouse_entered_unit(unit):
    units_under_mouse[unit] = true

func _mouse_exited_unit(unit):
    units_under_mouse[unit] = false

func _unit_disbanded(unit):
    if not is_instance_valid(selected_unit):
        deselect_unit()
        SignalBus.want_next_unit.emit(controller_team)
        return

    if selected_unit.is_queued_for_deletion():
        deselect_unit()
        SignalBus.want_next_unit.emit(controller_team)
        return

    if unit == selected_unit:
        deselect_unit()
        SignalBus.want_next_unit.emit(controller_team)
        return

func _unhandled_input(event):
    if event.is_action_pressed("click"):
        select_unit(get_first_mouseover_unit())
        return

    if try_input_to_unit(event):
        return

    if event.is_action_pressed('next'):
        SignalBus.want_next_unit.emit(controller_team)
        return

func try_input_to_unit(event) -> bool:
    if selected_unit == null:
        deactivate()
        return false

    if selected_unit.my_team != controller_team:
        deactivate()
        return false

    selected_unit.handle_cursor_input_event(event)

    # handle unit disappearing as result of move
    if not is_instance_valid(selected_unit):
        deselect_unit()
        return true

    if selected_unit.is_active():
        deactivate()
        # immediately hide the big circle
        # since presumably the human is already looking at this unit
        $big_circle.visible = false
    else:
        activate(selected_unit.position)

    return true

func _units_selected_next(unit):
    select_unit(unit)

func select_unit(unit):
    if unit == null:
        deselect_unit()
        return
    throbber_time = 0
    target_time = 0
    selected_unit = unit
    $big_circle.visible = true
    activate(unit.position)
    unit.select_me()

func deselect_unit():
    selected_unit = null
    deactivate()

func get_first_mouseover_unit() -> Area2D:
    for unit in units_under_mouse.keys():
        if units_under_mouse[unit] == false: continue
        return(unit)
    return null

func throb(delta):
    # animate alpha
    if throbber_time < throbber_duration:
        throbber_time += delta
        modulate.a = lerp(1.0, 0.25, throbber_time / throbber_duration)
    else:
        throbber_time = 0

func target(delta):
    if not $big_circle.visible: return
    target_time += delta
    $big_circle.modulate.a = lerp(1.0, 0.25, target_time / target_duration)
    if target_time > target_duration:
        target_time = 0
        $big_circle.visible = false

func activate(new_position):
    if not visible:
        throbber_time = 0
    position = new_position
    visible = true

func deactivate():
    visible = false
