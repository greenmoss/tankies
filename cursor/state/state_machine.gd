extends "res://common/state_machine.gd"

@onready var build = $build
@onready var city = $city
@onready var find_unit = $find_unit
@onready var none = $none
@onready var track_unit = $track_unit
@onready var unit = $unit
@onready var units = $units


func _ready():

    states_map = {
        "build": build,
        "city": city,
        "find_unit": find_unit,
        "none": none,
        "track_unit": track_unit,
        "unit": unit,
        "units": units,
    }


func mark_city(marked_city:City):
    if marked_city == null:
        return
    city.marked = marked_city
    current_state.emit_signal("next_state", "city")


func mark_unit(marked_unit:Unit):
    if marked_unit == null:
        return
    unit.marked = marked_unit
    current_state.emit_signal("next_state", "unit")
