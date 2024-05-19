extends Vision
class_name TeamVision

# we use dict instead of array
# because we want to avoid duplicate coordinates
# to do that in gdscript we use a dict with coordinates as keys
var explored:Dictionary
# TODO: var obscured:Dictionary
var visible:Dictionary

var my_city_vision:Dictionary
var my_unit_vision:Dictionary


func _ready():
    # vision is union of all cities and units
    # unlike cities and units, there is no additional vision distance
    distance = 0

    explored = {}
    visible = {}
    SignalBus.city_updated_vision.connect(_city_updated_vision)
    SignalBus.unit_updated_vision.connect(_unit_updated_vision)


func _city_updated_vision(city:City):
    if city.my_team != owner.name: return
    sum_cities()
    derive()


func _unit_updated_vision(unit:Unit):
    if unit.my_team != owner.name: return
    sum_units()
    derive()


# from unit and city vision
# derive currently visible
# derive previously explored
func derive():
    visible = {}
    for city_coordinates in my_city_vision.keys():
        explored[city_coordinates] = true
        visible[city_coordinates] = true
    for unit_coordinates in my_unit_vision.keys():
        explored[unit_coordinates] = true
        visible[unit_coordinates] = true


func has_explored_position(position:Vector2) -> bool:
    var coordinate = convert_from_world_position(position)
    if coordinate in explored.keys():
        if explored[coordinate] == true:
            return true
    return false


func sees_position(position:Vector2) -> bool:
    var coordinate = convert_from_world_position(position)
    if coordinate in visible.keys():
        if visible[coordinate] == true:
            return true
    return false


func sum_cities():
    my_city_vision = {}
    for city in owner.get_my_cities():
        for city_coordinates in city.vision.coordinates:
            my_city_vision[city_coordinates] = true


func sum_units():
    my_unit_vision = {}
    if owner.units == null: return
    for unit in owner.get_my_valid_units():
        if unit.vision == null: continue
        for unit_coordinates in unit.vision.coordinates:
            my_unit_vision[unit_coordinates] = true


func update_all():
    sum_cities()
    sum_units()
    derive()
