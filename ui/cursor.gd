extends Sprite2D

var time = 0
var duration = 1.5  # duration of the cursor throbber animation
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

func _mouse_entered_unit(unit):
    units_under_mouse[unit] = true

func _mouse_exited_unit(unit):
    units_under_mouse[unit] = false

func _unit_disbanded(unit):
    if selected_unit == null:
        return

    if not is_instance_valid(selected_unit):
        print("here1")
        deselect_unit()
        return

    if unit == selected_unit:
        deselect_unit()
        return

func _unhandled_input(event):
    if event.is_action_pressed("click"):
        selected_unit = select_first_mouseover_unit()
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

    if selected_unit.is_moving():
        deactivate()
    else:
        activate(selected_unit.position)

    return true

func _units_selected_next(unit):
    selected_unit = unit
    activate(unit.position)

func deselect_unit():
    selected_unit = null
    deactivate()

func select_first_mouseover_unit() -> Area2D:
    for unit in units_under_mouse.keys():
        if units_under_mouse[unit] == false: continue
        return(unit)
    return null

func throb(delta):
    # animate alpha
    if time < duration:
        time += delta
        modulate.a = lerp(1.0, 0.25, time / duration)
    else:
        time = 0

func activate(new_position):
    if not visible:
        time = 0
    position = new_position
    visible = true

func deactivate():
    visible = false
