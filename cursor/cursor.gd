extends Node2D
class_name Cursor

var cities_under_mouse:Dictionary
var units_under_mouse:Dictionary
var controller_team:String

@onready var state = $state

signal want_nearest_unit
signal want_next_unit


func _ready():
    cities_under_mouse = {}
    units_under_mouse = {}
    SignalBus.unit_disbanded.connect(_unit_disbanded)
    SignalBus.mouse_entered_city.connect(_mouse_entered_city)
    SignalBus.mouse_exited_city.connect(_mouse_exited_city)
    SignalBus.mouse_entered_unit.connect(_mouse_entered_unit)
    SignalBus.mouse_exited_unit.connect(_mouse_exited_unit)


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


func set_controller_team(team_name:String):
    controller_team = team_name

