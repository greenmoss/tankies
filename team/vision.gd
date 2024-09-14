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

signal derived


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
    for city_coordinate in my_city_vision.keys():
        explored[city_coordinate] = true
        visible[city_coordinate] = true
    for unit_coordinate in my_unit_vision.keys():
        explored[unit_coordinate] = true
        visible[unit_coordinate] = true
    derived.emit()


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


func reset(terrain:Terrain):
    explored = {}
    if terrain == null: return
    for cell in terrain.get_used_cells():
        # terrain map coordinate returns typeof() 5
        # Vector2 is typeof() 6, so convert
        var coordinate:Vector2 = cell
        explored[coordinate] = false

    sum_cities()
    sum_units()
    derive()


func sum_cities():
    my_city_vision = {}
    for city in owner.get_my_cities():
        # when we load saved cities, they start with null vision
        if city.vision == null: continue
        for city_coordinate in city.vision.coordinates:
            my_city_vision[city_coordinate] = true


func sum_units():
    my_unit_vision = {}
    if owner.units == null: return
    for unit in owner.get_my_valid_units():
        # when we load saved units, they start with null vision
        if unit.vision == null: continue
        for unit_coordinate in unit.vision.coordinates:
            my_unit_vision[unit_coordinate] = true


func tally_explored() -> Dictionary:
    var totals = {
        'explored': 0,
        'unexplored': 0
    }
    for coordinate in explored.keys():
        if explored[coordinate] == true:
            totals['explored'] += 1
        else:
            totals['unexplored'] += 1
    return totals
