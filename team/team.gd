extends Node

@export var color : Color
@export var controller: Global.Controllers

var units : Node = null

func _ready():
    SignalBus.want_next_unit.connect(_handle_next_unit_signals)
    SignalBus.unit_completed_moves.connect(_handle_next_unit_signals)
    SignalBus.city_captured.connect(_city_captured)
    # if we are an instance in the world, find our units
    # otherwise, we are only a scene without units
    units = find_child('units', false)

func _city_captured(city):
    if city.my_team != name: return
    select_next_unit()

func _handle_next_unit_signals(wanted_team):
    if wanted_team != name: return
    select_next_unit()

func build_unit_in(city):
    var new_unit = $units.create(city.my_team, city.position)
    new_unit.enter_city(city)

func is_done():
    return units.are_done()

func refill_moves():
    units.refill_moves()

func select_next_unit():
    units.select_next()
