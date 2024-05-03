extends Node

# we use dict instead of array
# because we want to avoid duplicate positions/coordinates
# to do that in gdscript we use a dict with positions/coordinates as keys
var explored:Dictionary
var visible:Dictionary

var my_city_vision:Dictionary
var my_unit_vision:Dictionary

var cities_seen:Dictionary
var units_seen:Dictionary


func _ready():
    explored = {}
    visible = {}
    SignalBus.city_updated_vision.connect(_city_updated_vision)
    SignalBus.unit_updated_vision.connect(_unit_updated_vision)

    set_city_vision()
    set_unit_vision()
    update()


func _city_updated_vision(city:City):
    if city.my_team != owner.name: return
    set_city_vision()
    update()


func _unit_updated_vision(unit:Unit):
    if unit.my_team != owner.name: return
    set_unit_vision()
    update()


func set_city_vision():
    my_city_vision = {}
    for city in owner.get_my_cities():
        for position in city.vision.positions:
            my_city_vision[position] = true


func set_unit_vision():
    my_unit_vision = {}
    if owner.units == null: return
    for unit in owner.get_my_valid_units():
        if unit.vision == null: continue
        for position in unit.vision.positions:
            my_unit_vision[position] = true


func update():
    visible = {}
    for position in my_city_vision.keys():
        explored[position] = true
        visible[position] = true
    for position in my_unit_vision.keys():
        explored[position] = true
        visible[position] = true
    print("for team ",owner.name," visible count is ",visible.size()," and explored count is ",explored.size())
