extends "res://common/state_machine.gd"

@onready var city = $city
@onready var find_unit = $find_unit
@onready var none = $none
@onready var track_unit = $track_unit
@onready var unit = $unit


func _ready():

    states_map = {
        "city": city,
        "find_unit": find_unit,
        "none": none,
        "track_unit": track_unit,
        "unit": unit,
    }


func mark_unit(marked_unit):
    unit.marked = marked_unit
    current_state.emit_signal("next_state", "unit")
