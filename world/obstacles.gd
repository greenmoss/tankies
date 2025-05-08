extends Node2D
class_name Obstacles

var points:Dictionary
var objects:Dictionary
var x_max:int
var x_min:int
var y_max:int
var y_min:int


func _ready():
    SignalBus.unit_moved_to_position.connect(_unit_moved_to_position)
    SignalBus.unit_disbanded.connect(_unit_disbanded)
    initialize()


func _unit_disbanded(unit:Unit):
    if not unit in objects:
        push_warning("while disbanding unit "+str(unit)+", not found in objects; points dict might be inconsistent")
        return

    var unit_point = objects[unit]
    remove_from(unit_point, unit)


func _unit_moved_to_position(unit:Unit, new_position:Vector2):
    var new_point = Global.as_grid(new_position)

    if unit in objects:
        var unit_old_point = objects[unit]
        remove_from(unit_old_point, unit)

    # if unit is newly created, it will not yet be in objects
    else:
        objects[unit] = new_point

    add_unique(new_point, unit)


func add_unique(point:Vector2i, object):
    objects[object] = point

    if object in points[point]:
        return

    points[point].append(object)


func get_filled_points() -> Dictionary:
    var filled_points = {}
    for point in points:
        if points[point].size() == 0:
            continue
        filled_points[point] = points[point]

    return filled_points


func initialize():
    # TODO: derive these from tile map
    x_max = 23
    x_min = 0
    y_max = 13
    y_min = 0

    for x in range(x_min, x_max + 1):
        for y in range(y_min, y_max + 1):
            points[Vector2i(x,y)] = []

    objects = {}


func remove_from(point:Vector2i, object):
    var cleaned = []

    for old_object in points[point]:
        if old_object == null: continue
        if not is_instance_valid(old_object): continue
        if old_object.is_queued_for_deletion(): continue
        if old_object == object: continue
        cleaned.append(old_object)

    points[point] = cleaned

    if object in objects:
        objects.erase(object)


func set_from_cities(cities:Cities):
    for city in cities.get_children():
        add_unique(Global.as_grid(city.position), city)


func set_from_units(units:Units):
    for unit in units.get_all_valid():
        add_unique(Global.as_grid(unit.position), unit)
