extends Node
class_name Plan

var _path = PackedVector2Array()

var goto_unit:Unit


func _ready():
    _path.clear()


# true if we set our path
# false if we could not create a path
func set_path_to_position(destination:Vector2, terrain:TileMap) -> bool:
    if not terrain.is_point_walkable(destination):
        return false

    if _path.is_empty():
        _path = terrain.find_path(owner.position, destination)

    # destination changed, so recalculate
    if destination != _path[-1]:
        _path = terrain.find_path(owner.position, destination)

    if owner.position == _path[0]:
        _path.remove_at(0)

    # reached end of path
    if _path.is_empty():
        return false

    return true
