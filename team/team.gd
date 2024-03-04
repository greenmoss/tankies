extends Node

class_name Team

@export var color : Color
@export var controller: Global.Controllers

@export var enemy_team: Team
@export var terrain: TileMap

var units : Node = null
var enemy_units: Node = null

func _ready():
    SignalBus.want_next_unit.connect(_handle_next_unit_signals)
    SignalBus.unit_completed_moves.connect(_handle_next_unit_signals)
    SignalBus.city_captured.connect(_city_captured)
    # if we are an instance in the world, find our units
    # otherwise, we are only a scene without units
    units = find_child('units', false)
    if enemy_team != null:
        enemy_units = enemy_team.units

func _city_captured(city):
    if city.my_team != name: return
    await move_next_unit()

func _handle_next_unit_signals(wanted_team):
    if wanted_team != name: return
    await move_next_unit()

func build_unit_in(city):
    var new_unit = $units.create(city.my_team, city.position)
    await new_unit.enter_city(city)

func is_done():
    return units.are_done()

func refill_moves():
    await units.refill_moves()

func move_next_unit():
    print("WARNING: ignoring stub call to move_next_unit for team ", self)
