extends Area2D

var selected = false
var mouse_is_over_me = false

@export var city_name = "City"

var contains_unit = null

func _ready():
    position = position.snapped(Vector2.ONE * Global.tile_size/2)

func occupied():
    if(contains_unit == null):
        return(false)
    return(true)

func occupy(unit):
    if(occupied()):
        print("Warning: refusing to add a unit to previously-occupied city")
        return
    contains_unit = unit

func vacate(unit):
    if(! occupied()):
        print(
            "Warning: refusing to remove unit ",
            unit,
            " from city, which is unoccupied ")
        return
    if(contains_unit != unit):
        print(
            "Warning: refusing to remove unit ",
            unit,
            " from city, which is already occupied by unit ",
            contains_unit)
        return
    contains_unit = null
