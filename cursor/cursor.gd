extends Node2D
class_name Cursor

#REF
#var throbber_time = 0
#var throbber_duration = 1.5  # duration of the cursor throbber animation
#var target_time = 0
#var target_duration = 0.75  # duration of the cursor target animation
var cities_under_mouse:Dictionary
var units_under_mouse:Dictionary
#REF
#var selected_city:City
#var selected_unit:Unit
var controller_team:String

@onready var state = $state

signal want_nearest_unit
signal want_next_unit


func _ready():
    cities_under_mouse = {}
    units_under_mouse = {}
    #REF
    #selected_city = null
    #selected_unit = null
    #SignalBus.unit_completed_moves.connect(_unit_completed_moves)
    SignalBus.unit_disbanded.connect(_unit_disbanded)
    #REF
    #SignalBus.units_selected_next.connect(_units_selected_next)
    SignalBus.mouse_entered_city.connect(_mouse_entered_city)
    SignalBus.mouse_exited_city.connect(_mouse_exited_city)
    SignalBus.mouse_entered_unit.connect(_mouse_entered_unit)
    SignalBus.mouse_exited_unit.connect(_mouse_exited_unit)


#REF
#func _physics_process(delta):
#    if selected_unit == null:
#        unmark_unit()
#        return
#
#    if not is_instance_valid(selected_unit):
#        unmark_unit()
#        return
#
#    if selected_unit.state.is_active():
#        deactivate()
#        return
#
#    if selected_unit.state.is_named('sleep'):
#        deactivate()
#        signal_for_next_unit(selected_unit)
#        return
#
#    activate(selected_unit.position)
#    throb(delta)
#    target(delta)


func _mouse_entered_city(city:City):
    if city.my_team != controller_team: return
    cities_under_mouse[city] = true


func _mouse_exited_city(city:City):
    cities_under_mouse[city] = false


func _mouse_entered_unit(unit:Unit):
    if not is_instance_valid(unit): return
    if unit.is_queued_for_deletion(): return
    if unit.my_team != controller_team: return
    units_under_mouse[unit] = true


func _mouse_exited_unit(unit:Unit):
    if not is_instance_valid(unit): return
    units_under_mouse[unit] = false


#REF
#func _unit_completed_moves(unit_team):
#    if unit_team != controller_team: return
#    signal_for_next_unit(null)


func _unit_disbanded(_unit:Unit):
    '''
    Remove any invalid units that we are tracking.

    If needed, signal to select a new unit.
    '''
    var new_units_under_mouse = {}
    for unit in units_under_mouse.keys():
        if not is_instance_valid(unit): continue
        if unit.is_queued_for_deletion(): continue
        new_units_under_mouse[unit] = units_under_mouse[unit]
    units_under_mouse = new_units_under_mouse
#REF
#    if not units_under_mouse.has(selected_unit):
#        signal_for_next_unit(null)


func set_controller_team(team_name:String):
    controller_team = team_name


#REF
#func _unhandled_input(event):
#    if event.is_action_pressed("click"):
#        var clicked_unit:Unit = get_first_mouseover_unit()
#        if clicked_unit == null:
#             unmark_unit()
#             return
#
#        mark_unit(clicked_unit)
#        send_input_to_unit(event)
#        return
#
#    if event.is_action_pressed('next'):
#        if selected_unit == null:
#            want_nearest_unit.emit(position)
#            return
#
#        signal_for_next_unit(selected_unit)
#        return
#
#    send_input_to_unit(event)
#    return
#
#
#func _units_selected_next(unit):
#    mark_unit(unit)
#
#
#func signal_for_next_unit(previous_unit):
#    if previous_unit == null:
#        unmark_unit()
#        want_nearest_unit.emit(position)
#        return
#
#    if not is_instance_valid(previous_unit):
#        unmark_unit()
#        want_nearest_unit.emit(position)
#        return
#
#    if previous_unit.is_queued_for_deletion():
#        unmark_unit()
#        want_nearest_unit.emit(position)
#        return
#
#    unmark_unit()
#    want_next_unit.emit(previous_unit)
#
#
#func send_input_to_unit(event):
#    if selected_unit == null:
#        unmark_unit()
#        return
#
#    # handle unit disappearing as result of move
#    if not is_instance_valid(selected_unit):
#        unmark_unit()
#        return
#
#    if selected_unit.state.is_active():
#        deactivate()
#        # immediately hide the big circle
#        # since presumably the human is already looking at this unit
#        return
#
#    selected_unit.handle_cursor_input_event(event)
#
#
#func mark_unit(unit):
#    if unit == null:
#        unmark_unit()
#        return
#    throbber_time = 0
#    target_time = 0
#    selected_unit = unit
#    $big_circle.visible = true
#    activate(unit.position)
#    unit.select_me()
#
#
#func unmark_unit():
#    selected_unit = null
#    deactivate()
#
#
#func get_first_mouseover_unit() -> Unit:
#    for unit in units_under_mouse.keys():
#        if units_under_mouse[unit] == false: continue
#        return(unit)
#    return null
#
#
#func throb(delta):
#    # animate alpha
#    if throbber_time < throbber_duration:
#        throbber_time += delta
#        modulate.a = lerp(1.0, 0.25, throbber_time / throbber_duration)
#    else:
#        throbber_time = 0
#
#
#func target(delta):
#    if not $big_circle.visible: return
#    target_time += delta
#    $big_circle.modulate.a = lerp(1.0, 0.25, target_time / target_duration)
#    if target_time > target_duration:
#        target_time = 0
#        $big_circle.visible = false
#
#
#func activate(new_position):
#    if not visible:
#        throbber_time = 0
#    position = new_position
#    visible = true
#
#
#func deactivate():
#    visible = false
#    $big_circle.visible = false
