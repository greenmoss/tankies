extends Node
class_name Vision
# Base interface for vision
# Could be one unit, one city, or a whole team

# NOTE: TileMap layer uses its own coordinates system
# This is different than the global positions
# For example, world position [80,80] converts to tilemap coordinate [1,1]
var coordinates:Array[Vector2]
var distance:int


# convert from world position to vision/tilemap coordinate
func convert_from_world_position(position:Vector2) -> Vector2:
    var view_coordinate = position
    view_coordinate.x = ceil(view_coordinate.x / Global.tile_size)
    view_coordinate.y = ceil(view_coordinate.y / Global.tile_size)
    return view_coordinate


func get_neighbor_coordinates(view_coordinate:Vector2, view_distance:int) -> Array[Vector2]:
    var neighbor_coordinates:Array[Vector2] = []

    for x_offset in range(-1*view_distance, view_distance+1):
        for y_offset in range(-1*view_distance, view_distance+1):
            neighbor_coordinates.append(Vector2(view_coordinate.x + x_offset, view_coordinate.y + y_offset))

    return neighbor_coordinates


func set_from_coordinate(coordinate:Vector2) -> bool:
    var neighbor_coordinates = get_neighbor_coordinates(coordinate, distance)

    if coordinates == neighbor_coordinates:
        return false

    coordinates = neighbor_coordinates
    return true
