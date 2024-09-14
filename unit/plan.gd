extends Node
class_name Plan

var goto_city:City = null
var goto_unit:Unit = null
var path_to_city:PackedVector2Array
var path_to_unit:PackedVector2Array


func _ready():
    path_to_city.clear()
    path_to_unit.clear()


# true if we set our path
# false if we could not create a path
func set_path_to_city(target_city:City, terrain:TileMapLayer) -> bool:
    path_to_city = create_path(path_to_city, target_city.position, terrain, owner.navigation)

    if path_to_city.is_empty():
        goto_city = null
        return false

    goto_city = target_city
    return true


# true if we set our path
# false if we could not create a path
func set_path_to_unit(target_unit:Unit, terrain:TileMapLayer) -> bool:
    path_to_unit = create_path(path_to_unit, target_unit.position, terrain, owner.navigation)

    if path_to_unit.is_empty():
        goto_unit = null
        return false

    goto_unit = target_unit
    return true


# set_path is reserved, so don't use that name for this function
func create_path(path:PackedVector2Array, destination:Vector2, terrain:TileMapLayer, navigation_name:String) -> PackedVector2Array:
    if not terrain.is_point_walkable(destination, navigation_name):
        path.clear()
        return path

    if path.is_empty():
        path = terrain.find_path(owner.position, destination, navigation_name)

    # destination changed, so recalculate
    if destination != path[-1]:
        path = terrain.find_path(owner.position, destination, navigation_name)

    if owner.position == path[0]:
        path.remove_at(0)

    return path
